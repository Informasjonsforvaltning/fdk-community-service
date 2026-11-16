'use strict';

const plugin = {};

plugin.init = async (params) => {
	const { router } = params;
	const routeHelpers = require.main.require('./src/routes/helpers');

	routeHelpers.setupPageRoute(router, '/consent', [], (req, res) => {
		res.render('consent');
	});
};


module.exports = plugin;
