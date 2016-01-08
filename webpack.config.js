const path = require('path');
const webpack = require('webpack');

const loaderConfigs = [
  {
    test: /\.coffee$/,
    loader: 'coffee-loader'
  },
  {
    test: /\.elm$/,
    exclude: [/elm-stuff/, /node_modules/],
    loader: 'elm-webpack'
  },
];

const sourceRoot = path.join(__dirname, 'app', 'frontend');

const sources = {
  js: path.join(sourceRoot, 'javascripts'),
  elm: path.join(sourceRoot, 'elm'),
};

module.exports = {
  context: sourceRoot,
  entry: './javascripts/localdoc/entry.js',
  output: {
    path: path.join(__dirname, 'app', 'assets', 'javascripts'),
    filename: 'localdoc/bundle.js',
    publicPath: '/assets',
    devtoolModuleFilenameTemplate: '[resourcePath]',
    devtoolFallbackModuleFilenameTemplate: '[resourcePath]?[hash]'
  },
  resolve: {
    alias: {
      coffee: sources.js
    },
    root: [
      sources.js,
      sources.elm
    ],
    extensions: ['', '.js', '.coffee', '.elm'],
    modulesDirectories: ['node_modules']
  },
  plugins: [],
  module: {
    loaders: loaderConfigs,
    noParse: /.elm/
  }
};
