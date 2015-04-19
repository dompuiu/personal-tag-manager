/*
 * Webpack distribution configuration
 *
 * This file is set up for serving the distribution version. It will be compiled to dist/ by default
 */

'use strict';

var webpack = require('webpack');
var path = require("path");

module.exports = {

  output: {
    publicPath: '/assets/',
    path: 'dist/ui_app/assets/',
    filename: 'main.js'
  },

  debug: false,
  devtool: false,
  entry: './app/ui_app/scripts/main.js',

  stats: {
    colors: true,
    reasons: false
  },

  plugins: [
    new webpack.optimize.DedupePlugin(),
    new webpack.optimize.UglifyJsPlugin(),
    new webpack.optimize.OccurenceOrderPlugin(),
    new webpack.optimize.AggressiveMergingPlugin(),
    new webpack.ProvidePlugin({
      $: 'jquery',
      jQuery: 'jquery'
    })
  ],

  resolve: {
    root: [
      path.join(__dirname, "bower_components"),
      path.join(__dirname, "node_modules")
    ],
    extensions: ['', '.js'],
    alias: {
      'styles': __dirname + '/app/ui_app/styles',
      'mixins': __dirname + '/app/ui_app/scripts/mixins',
      'components': __dirname + '/app/ui_app/scripts/components/',
      'stores': __dirname + '/app/ui_app/scripts/stores/',
      'actions': __dirname + '/app/ui_app/scripts/actions/',
      'jquery': __dirname + '/bower_components/jquery/dist/jquery.min.js',
      'auth': __dirname + '/app/ui_app/scripts/auth/auth.js',
      'require_auth': __dirname + '/app/ui_app/scripts/auth/require_auth.js'
    }
  },

  module: {
    preLoaders: [{
      test: /ui_app\/.*\.js$/,
      exclude: /node_modules|bower_components/,
      loader: 'jsxhint'
    }],
    loaders: [{
      test: /\.js$/,
      exclude: /node_modules/,
      loader: 'react-hot!babel-loader'
    }, {
      test: /\.css$/,
      loader: 'style-loader!css-loader'
    }, {
      test: /\.(png|jpg)$/,
      loader: 'url-loader?limit=8192'
    }, {
      test: /\.woff2(\?v=\d+\.\d+\.\d+)?$/,
      loader: "url?limit=10000&minetype=application/font-woff"
    }, {
      test: /\.woff(\?v=\d+\.\d+\.\d+)?$/,
      loader: "url?limit=10000&minetype=application/font-woff"
    }, {
      test: /\.ttf(\?v=\d+\.\d+\.\d+)?$/,
      loader: "url?limit=10000&minetype=application/octet-stream"
    }, {
      test: /\.eot(\?v=\d+\.\d+\.\d+)?$/,
      loader: "file"
    }, {
      test: /\.svg(\?v=\d+\.\d+\.\d+)?$/,
      loader: "url?limit=10000&minetype=image/svg+xml"
    }]
  }
};
