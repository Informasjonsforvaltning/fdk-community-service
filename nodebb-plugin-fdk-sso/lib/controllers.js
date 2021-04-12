'use strict';

const Settings = require.main.require("./src/settings");

var Controllers = {};

Controllers.renderAdminPage = function(req, res, next) {
    /*
		Make sure the route matches your path to template exactly.
		If your route was:
			myforum.com/some/complex/route/
		your template should be:
			templates/some/complex/route.tpl
		and you would render it like so:
			res.render('some/complex/route');
	*/

    res.render('admin/plugins/fdk-sso', {});
};

Controllers.renderLoginPage = function(req, res, next) {
	res.statusCode=302;
	res.setHeader('Location','/');
	return res.end();
}


module.exports = Controllers;
