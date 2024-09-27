'use strict';

const nconf = require.main.require('nconf');
const winston = require.main.require('winston');
const routeHelpers = require.main.require('./src/routes/helpers');

const plugin = {};

plugin.init = async (params, callback) => {
	winston.info(`[plugins/fdk-resource-link] Initialization`);
};

module.exports = plugin;
