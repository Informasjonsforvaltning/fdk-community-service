import { static__app_load } from './hooks';

const winston = require.main?.require('winston');

const init: static__app_load = async () => {
  winston.info('[fdk-resource-link] Plugin initialised');
};

export default init;
