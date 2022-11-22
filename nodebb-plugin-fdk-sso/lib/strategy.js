var GrantManager = require("keycloak-connect/middleware/auth-utils/grant-manager"),
  Token = require("keycloak-connect/middleware/auth-utils/token"),
  Config = require("keycloak-connect/middleware/auth-utils/config"),
  Keycloak = require("keycloak-connect"),
  uuid = require("uuid"),
  URLUtil = require("url"),
  winston = require("winston");

function Strategy(options, verify) {
  this.callbackUrl = options.callbackURL;
  this.config = new Config(options.keycloakConfig);
  this.grantManager = new GrantManager(this.config);
  this.validRedirectsHosts = options.validRedirectsHosts || [];
  this.name = "keycloak";
  this.verify = verify;
}

Strategy.SESSION_KEY = "keycloak-token";

Strategy.prototype.authenticate = function (req, options) {
  var self = this;
  if (req.query && req.query.error) {
    return this.fail(req.query.error);
  }

  function verified(err, user, info) {
    if (err) {
      return self.error(err);
    }
    if (!user) {
      return self.fail(info);
    }
    self.success(user, info);
  }

  this.getGrant(req)
    .then((grant) => {
      self.verify(grant, req, verified);
    })
    .catch(() => {
      if (req.query.auth_callback) {
        var sessionId = req.session ? req.session.id : undefined;
        var state = req.session ? req.session.id : undefined;
        this.getGrantFromCode(req, req.query.code, sessionId).then((grant) => {
          if (req.session) {
            req.session[Strategy.SESSION_KEY] = grant.__raw;
          }
          self.redirect(self.cleanUrl(req));
        });
      } else {
        var loginURL = this.loginUrl(uuid.v4(), this.getRedirectURL(req));
        this.redirect(loginURL);
      }
    });
};

Strategy.prototype.getGrantFromCode = function (req, code, sessionId) {
  return this.grantManager
    .obtainFromCode(req, code, sessionId)
    .then((grant) => {
      return grant;
    });
};

Strategy.prototype.cleanUrl = function (req) {
  var urlParts = {
    pathname: req.path,
    query: req.query,
  };
  delete urlParts.query.code;
  delete urlParts.query.auth_callback;
  delete urlParts.query.state;
  delete urlParts.query.session_state

  return URLUtil.format(urlParts);
};

Strategy.prototype.getRedirectURL = function (req) {
  var host = req.hostname;
  if (req.headers["x-forwarded-host"]) {
    host = req.headers["x-forwarded-host"];
  }
  var headerHost = host.split(":");
  var port = headerHost[1] || "";
  var protocol = req.protocol;
  if (req.headers["x-forwarded-proto"] === "https") {
    protocol = "https";
  }
  var callbackUrl = this.callbackUrl;
  if (callbackUrl[0] !== "/") {
    callbackUrl = "/" + callbackUrl;
  }
  var redirectUrl =
    protocol +
    "://" +
    host +
    (port === "" ? "" : ":" + port) +
    callbackUrl +
    "?auth_callback=1";
  if (req.session) {
    req.session.auth_redirect_uri = redirectUrl;
    try {
      if (
        req.headers.referer &&
        this.validRedirectsHosts.indexOf(
          URLUtil.parse(req.headers.referer).hostname
        ) > -1
      ) {
        req.session.returnTo = req.headers.referer;
      }
    } catch (e) {}
  }
  return redirectUrl;
};

Strategy.prototype.getGrant = async function (req) {
  var grantData = req.session[Strategy.SESSION_KEY];
  if (typeof grantData === "string") {
    grantData = JSON.parse(grantData);
  }
  if (grantData && !grantData.error) {

    const grant = await this.grantManager.createGrant(
      JSON.stringify(grantData)
    );
    return this.grantManager.ensureFreshness(grant);
  }
  return Promise.reject();
};

Strategy.prototype.getToken = (rawToken) => new Token(rawToken);
Strategy.prototype.loginUrl = Keycloak.prototype.loginUrl;
Strategy.prototype.logoutUrl = Keycloak.prototype.logoutUrl;

exports = module.exports = Strategy;
exports.Strategy = Strategy;
