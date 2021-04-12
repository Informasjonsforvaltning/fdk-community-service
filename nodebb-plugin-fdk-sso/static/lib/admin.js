'use strict';
/* globals $, define, socket */

define('admin/plugins/fdk-sso', ['settings'], function(Settings) {

    var ACP = {};

    ACP.init = function() {

        var wrapper = $('#fdk-sso-settings');
        Settings.sync('fdk-sso', wrapper);

        $('#save').on('click', function() {
            event.preventDefault();
            Settings.persist('fdk-sso', wrapper, function() {
                socket.emit('admin.settings.syncSsoKeycloak');
            });
        });
    };

    return ACP;
});
