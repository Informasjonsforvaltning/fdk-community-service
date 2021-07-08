'use strict';

const nconf = require.main.require('nconf');
const winston = require.main.require('winston');

const plugin = {};

plugin.init = async (params) => {
	const { router, middleware } = params;
	const routeHelpers = require.main.require('./src/routes/helpers');

	routeHelpers.setupPageRoute(router, '/consent', middleware, [(req, res, next) => {
		winston.info(`[plugins/consent] In middleware. This argument can be either a single middleware or an array of middlewares`);
		setImmediate(next);
	}], (req, res) => {
		winston.info(`[plugins/consent] Navigated to ${nconf.get('relative_path')}/consent`);
		res.render('consent');
	});
};


module.exports = plugin;
