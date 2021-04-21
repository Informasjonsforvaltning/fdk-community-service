'use strict';

(function (module) {
  const passport = require.main.require("passport");
  const winston = require.main.require("winston");
  const async = require.main.require("async");
  const nconf = require.main.require("nconf");
  const format = require("util").format;

  const User = require.main.require("./src/user");
  const Groups = require.main.require("./src/groups");
  const db = require.main.require("./src/database");
  const Settings = require.main.require("./src/settings");
  const SocketAdmin = require.main.require("./src/socket.io/admin");
  const authenticationController = require.main.require(
    "./src/controllers/authentication"
  );

  const controllers = require("./lib/controllers");
  const Strategy = require("./lib/strategy");

  const plugin = {
    ready: false,
    name: "fdk-sso",
  };

  SocketAdmin.settings.syncSsoKeycloak = () => {
    if (settings) {
      settings.sync(() => {
        winston.info("[fdk-sso] settings is reloaded");
      });
    }
  };
  let settings;
  plugin.init = (params, callback) => {
    const router = params.router,
      hostMiddleware = params.middleware;

    router.get(
      "/admin/plugins/fdk-sso",
      hostMiddleware.admin.buildHeader,
      controllers.renderAdminPage
    );
    router.get("/api/admin/plugins/fdk-sso", controllers.renderAdminPage);

    settings = new Settings("fdk-sso", "0.0.1", {}, () => {
      plugin.validateSettings(settings.get(), (err) => {
        if (err) {
          callback();
          return;
        }
        plugin.settings = settings.get();
        let adminUrl = plugin.settings["admin-url"];
        if (adminUrl[0] !== "/") {
          adminUrl = "/" + adminUrl;
        }
        if (adminUrl[adminUrl.length - 1] !== "/") {
          adminUrl += "/";
        }
        adminUrl += "k_logout";
        router.post(adminUrl, plugin.adminLogout);
        callback();
      });
    });
  };

  plugin.logout = (data, callback) => {
    const req = data.req;
    if (req.session) {
      delete req.session[Strategy.SESSION_KEY];
    }
    callback();
  };

  plugin.adminLogout = (request, response) => {
    const doLogout = (data, callback) => {
      if (typeof data !== "string" || data.indexOf(".") < 0) {
        return callback(new Error("invalid payload"));
      }
      try {
        const parts = data.split(".");
        const payload = JSON.parse(new Buffer(parts[1], "base64").toString());
        if (payload && payload.action && payload.action === "LOGOUT") {
          const sessionIDs = payload.adapterSessionIds;
          if (sessionIDs && sessionIDs.length > 0) {
            let seen = 0;
            sessionIDs.forEach((sessionId) => {
              db.sessionStore.get(sessionId, (err, sessionObj) => {
                if (err) {
                  winston.info(
                    "[fdk-sso] user logout unsucessful" + err.message
                  );
                }
                if (sessionObj && sessionObj.passport) {
                  const uid = sessionObj.passport.user;
                  async.parallel(
                    [
                      (next) => {
                        if (
                          sessionObj &&
                          sessionObj.meta &&
                          sessionObj.meta.uuid
                        ) {
                          db.deleteObjectField(
                            "uid:" + uid + ":sessionUUID:sessionId",
                            sessionObj.meta.uuid,
                            next
                          );
                        } else {
                          next();
                        }
                      },
                      async.apply(
                        db.sortedSetRemove,
                        "uid:" + uid + ":sessions",
                        sessionId
                      ),
                      async.apply(
                        db.sessionStore.destroy.bind(db.sessionStore),
                        sessionId
                      ),
                    ],
                    () => {
                      winston.info("[fdk-sso] Revoked user session: " + sessionId);
                    }
                  );
                }
              });
              ++seen;
              if (seen === sessionIDs.length) {
                return callback(null, "ok");
              }
            });
          } else {
            return callback(new Error("User logout unsucessful."));
          }
        } else {
          return callback(new Error("User logout unsucessful."));
        }
      } catch (err) {
        return callback(new Error("User logout unsucessful."));
      }
    }

    let reqData = "";
    request.on("data", (d) => {
      reqData += d.toString();
    });

    request.on("end", () => {
      return doLogout(reqData, (err, result) => {
        if (err) {
          return response.send(err.message);
        }
        response.send(result);
      });
    });
  };

  plugin.getStrategy = (strategies, callback) => {
    if (plugin.ready && plugin.keycloakConfig) {
      winston.info("[fdk-sso] Plugin ready");
      plugin.strategy = new Strategy(
        {
          callbackURL: plugin.settings["callback-url"],
          keycloakConfig: plugin.keycloakConfig,
          validRedirectsHosts: plugin.validRedirects,
        },
        (userData, req, done) => {
          plugin.parseUserReturn(userData, (err, profile) => {
            if (err) {
              return done(err);
            }
            plugin.login(profile, (err, user) => {
              if (err) {
                return done(err);
              }
              authenticationController.onSuccessfulLogin(req, user.uid);
              done(null, user);
            });
          });
        }
      );
      passport.use(plugin.name, plugin.strategy);
      strategies.push({
        name: plugin.name,
        url: "/auth/" + plugin.name,
        callbackURL: plugin.settings["callback-url"],
        icon: "fa-user",
        scope: (plugin.settings.scope || "").split(","),
        successUrl: "/",
      });
    } else {
      winston.error(
        "[fdk-sso] Configuration is invalid, plugin will not be actived."
      );
    }
    callback(null, strategies);
  };

  plugin.parseUserReturn = (userData, callback) => {
    const hasAuthorityMatch = (authority) => {
      const [resource, resourceId, role] = authority.split(':');
      const authorities = userData.access_token.content.authorities?.split(',');
      for (let i = 0; i < authorities.length; i++) {
        const [clientResource, clientResourceId, clientRole] = authorities[i].split(':');
        if((resource === '*' || resource === clientResource) &&
          (resourceId === '*' || resourceId === clientResourceId) &&
          (role === '*' || role === clientRole)) {
            return true;
          }
      }

      return false;
    }

    const profile = {};
    for (const key in plugin.tokenMapper) {
      if (plugin.tokenMapper.hasOwnProperty(key)) {
        profile[key] = userData.id_token.content[plugin.tokenMapper[key]];
      }
    }
    if (plugin.clientRoleToGroupMapper) {
      profile.joinGroups = [];
      profile.leaveGroups = [];

      const authorities = Object.keys(plugin.clientRoleToGroupMapper);
      for (let i = 0; i < authorities.length; i++) {
        const authority = authorities[i];
        if (hasAuthorityMatch(authority)) {
          profile.joinGroups = profile.joinGroups.concat(plugin.clientRoleToGroupMapper[authority]);
        }
      }
      profile.leaveGroups = plugin.allRoleGroups.filter((role) => {
        return profile.joinGroups.indexOf(role) == -1;
      });
    }
    callback(null, profile);
  };

  plugin.login = (payload, callback) => {

    const username = payload.email.replace(/@.*/, '');
    plugin.getUidByOAuthid(payload.id, (err, uid) => {
      if (err) {
        callback(err);
        return;
      }
      if (uid !== null) {
        async.parallel(
          [
            (callback) => {
              if (payload.joinGroups) {
                for (let i = 0; i < payload.joinGroups.length; i++) {
                  const group = payload.joinGroups[i];
                  Groups.join(group, uid, (err) => {
                    if (err) {
                      winston.info(
                        `[fdk-sso] uid:${uid} unable to join ${group} on login. err: ${err}`
                      );
                    }
                  });
                }
              }
              if (payload.leaveGroups) {
                for (let i = 0; i < payload.leaveGroups.length; i++) {
                  const group = payload.leaveGroups[i];
                  Groups.leave(group, uid, (err) => {
                    if (err) {
                      winston.info(
                        `[fdk-sso] uid:${uid} unable to leave ${group} on login. err: ${err}`
                      );
                    }
                  });
                }
              }
              callback(null);
            },
            (callback) => {
              User.getUserField(uid, "username", (err, oldUsername) => {
                if (err) {
                  return callback(err);
                }
                if (oldUsername === username) {
                  return callback(null, "Username not changed");
                }
                User.updateProfile(
                  uid,
                  {
                    uid,
                    username,
                    email: payload.email,
                    fullname: payload.fullname
                  }
                );
              });
            },
          ],
          (err, result) => {
            if (err) {
              return winston.error(`[fdk-sso] ${err}`);
            }
            callback(null, { uid: uid });
          }
        );
      } else {
        // New User
        const success = (uid) => {
          // Save provider-specific information to the user
          User.setUserField(uid, plugin.name + "Id", payload.id);
          db.setObjectField(plugin.name + "Id:uid", payload.id, uid);

          if (
            payload.hasOwnProperty("facebook_id") &&
            typeof payload["facebook_id"] !== "undefined"
          ) {
            payload.picture =
              "https://graph.facebook.com/v2.8/" +
              payload["facebook_id"] +
              "/picture?type=large";
          }

          if (payload.picture) {
            User.setUserField(uid, "uploadedpicture", payload.picture);
            User.setUserField(uid, "picture", payload.picture);
          }

          if (payload.joinGroups) {
            for (let i = 0; i < payload.joinGroups.length; i++) {
              const group = payload.joinGroups[i];
              Groups.join(group, uid, (err) => {
                if (err) {
                  winston.info(
                    `[fdk-sso] uid:${uid} unable to join ${group} on login. err: ${err}`
                  );
                }
              });
            }
          }
          if (payload.leaveGroups) {
            for (let i = 0; i < payload.leaveGroups.length; i++) {
              const group = payload.leaveGroups[i];
              Groups.leave(group, uid, (err) => {
                if (err) {
                  winston.info(
                    `[fdk-sso] uid:${uid} unable to leave ${group} on login. err: ${err}`
                  );
                }
              });
            }
          }
          callback(null, { uid: uid });
        };

        User.getUidByEmail(payload.email, (err, uid) => {
          if (err) {
            callback(err);
            return;
          }

          if (!uid) {
            User.create(
              {
                username: username,
                email: payload.email
              },
              (err, uid) => {
                if (err) {
                  callback(err);
                  return;
                }

                User.updateProfile(
                  uid,
                  {
                    uid,
                    fullname: payload.fullname
                  }
                );
                success(uid);
              }
            );
          } else {
            success(uid); // Existing account -- merge
          }
        });
      }
    });
  };

  plugin.getUidByOAuthid = (keycloakId, callback) => {
    db.getObjectField(plugin.name + "Id:uid", keycloakId, (err, uid) => {
      if (err) {
        return callback(err);
      }
      callback(null, uid);
    });
  };

  plugin.deleteUserData = (data, callback) => {
    const uid = data.uid;
    async.waterfall(
      [
        async.apply(User.getUserField, uid, plugin.name + "Id"),
        (keycloakIdToDelete, next) => {
          db.deleteObjectField(
            plugin.name + "Id:uid",
            keycloakIdToDelete,
            next
          );
        },
      ],
      (err) => {
        if (err) {
          winston.error(
            "[fdk-sso] Could not remove keycloak ID data for uid " +
              uid +
              ". Error: " +
              err
          );
          return callback(err);
        }
        winston.verbose(
          "[fdk-sso] sucessfully deleted keycloak data for  uid " + uid
        );
        callback(null, uid);
      }
    );
  };

  plugin.validateSettings = (settings, callback) => {
    let configOK = true;
    let errorMessage =
      "[fdk-sso] %s configuration value not found, fdk-sso is disabled.";
    let formattedErrMessage = "";
    "admin-url|callback-url|keycloak-config|token-mapper"
      .split("|")
      .forEach((key) => {
        if (!settings[key]) {
          formattedErrMessage = format(errorMessage, key);
          winston.error(formattedErrMessage);
          configOK = false;
        }
      });
    if (!configOK) {
      callback(new Error("failed to load settings"));
      return;
    }
    try {
      plugin.keycloakConfig = JSON.parse(settings["keycloak-config"]);
    } catch (e) {
      winston.error(
        "[fdk-sso] invalid keycloak configuration, fdk-sso is disabled."
      );
      callback(new Error("invalid keycloak configuration"));
      return;
    }

    try {
      plugin.tokenMapper = JSON.parse(settings["token-mapper"]);
    } catch (e) {
      winston.error("[fdk-sso] Token mapper, fdk-sso is disabled.");
      callback(new Error("invalid keycloak configuration"));
      return;
    }
    "id|email|fullname".split("|").forEach((key) => {
      if (!plugin.tokenMapper[key]) {
        formattedErrMessage = format(errorMessage, key);
        winston.error(formattedErrMessage);
        configOK = false;
      }
    });

    try {
      plugin.clientRoleToGroupMapper = JSON.parse(
        settings["client-role-to-group-mapper"]
      );
      plugin.allRoleGroups = [];
      for (const clientRole in plugin.clientRoleToGroupMapper) {
        if (plugin.clientRoleToGroupMapper.hasOwnProperty(clientRole)) {
          const roles = plugin.clientRoleToGroupMapper[clientRole];
          plugin.allRoleGroups = plugin.allRoleGroups.concat(roles);
        }
      }
    } catch (e) {
      winston.error(`[fdk-sso] Client rolet to group mapper invalid`);
    }

    try {
      plugin.validRedirects = settings["valid-redirects"].split(",");
    } catch (e) {
      winston.warn("[fdk-sso] validRedirects setting: " + e.message);
      plugin.validRedirects = [];
    }

    if (nconf.get("REALM_PUBLIC_KEY")) {
      winston.info(
        "[fdk-sso] realm-public-key override from environment variable"
      );
      plugin.keycloakConfig["realm-public-key"] = nconf.get("REALM_PUBLIC_KEY");
    }

    if (nconf.get("REALM")) {
      winston.info("[fdk-sso] realm override from environment variable");
      plugin.keycloakConfig["realm"] = nconf.get("REALM");
    }

    if (nconf.get("KEYCLOAK_RESOURCE")) {
      winston.info(
        "[fdk-sso] resource override from environment variable"
      );
      plugin.keycloakConfig["resource"] = nconf.get("KEYCLOAK_RESOURCE");
    }

    if (nconf.get("AUTH_SERVER_URL")) {
      winston.info(
        "[fdk-sso] auth-server-url override from environment variable"
      );
      plugin.keycloakConfig["auth-server-url"] = nconf.get("AUTH_SERVER_URL");
    }

    winston.info("[fdk-sso] Settings OK");
    plugin.settings = settings;
    plugin.ready = true;
    callback();
  };

  plugin.addAdminNavigation = (header, callback) => {
    header.plugins.push({
      route: "/plugins/fdk-sso",
      icon: "fa-user-secret",
      name: "FDK Single Sign-On",
    });

    callback(null, header);
  };

  plugin.getClientConfig = (config, next) => {
    if (plugin.keycloakConfig) {
      config.keycloak = {
        logoutUrl:
          plugin.keycloakConfig["auth-server-url"] +
          "/realms/" +
          plugin.keycloakConfig["realm"] +
          "/protocol/openid-connect/logout",
      };
    }
    next(null, config);
  };

  module.exports = plugin;
}(module));
