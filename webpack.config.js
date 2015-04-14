/*
 * Webpack development server configuration
 *
 * This file is set up for serving the webpack-dev-server, which will watch for changes and recompile as required if
 * the subfolder /webpack-dev-server/ is visited. Visiting the root will not automatically reload.
 */
'use strict';
var webpack = require('webpack');
var path = require("path");

module.exports = {

  output: {
    filename: 'main.js',
    publicPath: '/assets/'
  },

  cache: true,
  debug: true,
  devtool: false,
  entry: [
      'webpack/hot/only-dev-server',
      './app/ui_app/scripts/main.js'
  ],

  stats: {
    colors: true,
    reasons: true
  },

  resolve: {
    extensions: ['', '.js'],
    root: [
      path.join(__dirname, "bower_components"),
      path.join(__dirname, "node_modules")
    ],
    alias: {
      'styles': __dirname + '/app/ui_app/styles',
      'mixins': __dirname + '/app/ui_app/scripts/mixins',
      'components': __dirname + '/app/ui_app/scripts/components/',
      'stores': __dirname + '/app/ui_app/scripts/stores/',
      'actions': __dirname + '/app/ui_app/scripts/actions/',
      'jquery': __dirname + '/bower_components/jquery/dist/jquery.min.js',
      'auth': __dirname + '/app/ui_app/scripts/auth/auth.js'
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
  },

  plugins: [
    new webpack.HotModuleReplacementPlugin(),
    new webpack.NoErrorsPlugin(),
    new webpack.ProvidePlugin({
        $: 'jquery',
        jQuery: 'jquery'
    })
  ]

};
