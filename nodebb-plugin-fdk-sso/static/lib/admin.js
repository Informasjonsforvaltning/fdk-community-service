'use strict';
/* globals $, define, socket */

define('admin/plugins/fdk-sso', ['settings'], function(settings) {
  var ACP = {};

	ACP.init = function () {
		settings.load('fdk-sso', $('#fdk-sso-settings'), function () {});
		$('#save').on('click', saveSettings);
	};

	function saveSettings() {
		settings.save('fdk-sso', $('#fdk-sso-settings')); // pass in a function in the 3rd parameter to override the default success/failure handler
	}

	return ACP;  

});
