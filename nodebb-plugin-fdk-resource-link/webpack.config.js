/* eslint-disable @typescript-eslint/no-var-requires */

const webpack = require('webpack');
const TerserPlugin = require('terser-webpack-plugin');
const path = require('path');

module.exports = (env, argv) => {
  const prod = argv.mode !== 'development';

  const requirejsModules = new Set([
    'composer',
    'composer/formatting',
    'translator',
    'benchpress',
  ]);

  return {
    context: __dirname,
    mode: prod ? 'production' : 'development',
    devtool: prod ? 'source-map' : 'inline-source-map',
    entry: {
      client: './src/client/index',
    },
    output: {
      path: path.join(__dirname, './build/bundles'),
      filename: '[name].js',
      chunkFilename: '[name].[contenthash].js',
    },
    externals: [
      {
        jquery: 'jQuery',
        utils: 'utils',
      },
      (context, request, callback) => {
        if (requirejsModules.has(request)) {
          callback(null, `commonjs ${request}`);
          return;
        }

        callback();
      },
    ],
    resolve: {
      extensions: ['.js', '.ts'],
    },
    module: {
      rules: [
        {
          test: /\.ts$/,
          use: 'ts-loader',
          exclude: /node_modules/,
        },
      ],
    },
    optimization: {
      minimizer: [
        new TerserPlugin({
          terserOptions: {
            sourceMap: true,
          },
          parallel: true,
        }),
      ],
    },
  };
};
