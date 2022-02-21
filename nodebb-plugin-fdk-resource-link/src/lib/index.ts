import 'source-map-support/register';

import init from './init';

import {
  filter__composer_formatting,
} from './hooks';

const winston = require.main?.require('winston');

const composerFormatting: filter__composer_formatting = async (data) => {
  winston.info('[fdk-resource-link] Add composer formatting option');

  data.options.push({
    name: 'plugin-fdk-resource-link',
    className: 'plugin-fdk-resource-link-composer-edit-link',
    title: '[[fdk-resource-link:title]]',
  });
  return data;
};

export {
  init,
  composerFormatting,
};
