const path = require('path');
const webpack = require('webpack');
const neat = require("node-neat");
const sassPaths = neat.with([
    path.resolve(__dirname, "./app/frontend/sass")
  ]).map(function(sassPath) {
  return "includePaths[]=" + sassPath;
}).join("&");

const loaderConfigs = [
  {
    test: /\.coffee$/,
    loader: 'coffee-loader'
  },
  {
    test: /\.json$/,
    loader: 'json-loader'
  },
  {
    test: /\.elm$/,
    exclude: [/elm-stuff/, /node_modules/],
    loader: 'elm-webpack'
  },
  {
    test: /\.css$/,
    loader: "style!css?sourceMap",
  },
  {
    test: /\.sass$/,
    loader: "style!css?sourceMap!sass?indentedSyntax&sourceMap&" + sassPaths,
  },
];

const sourceRoot = path.join(__dirname, 'app', 'frontend');

const sources = {
  coffee: path.join(sourceRoot, 'coffee'),
  elm: path.join(sourceRoot, 'elm'),
  sass: path.join(sourceRoot, 'sass'),
};

module.exports = {
  context: sourceRoot,
  entry: './localdoc.js',
  output: {
    path: path.join(__dirname, 'app', 'assets', 'javascripts'),
    filename: 'localdoc/bundle.js',
    publicPath: '/assets',
    devtoolModuleFilenameTemplate: '[resourcePath]',
    devtoolFallbackModuleFilenameTemplate: '[resourcePath]?[hash]'
  },
  resolve: {
    root: [
      sources.coffee,
      sources.elm,
      sources.sass,
    ],
    extensions: ['', '.js', '.coffee', '.elm', '.sass', '.scss'],
    modulesDirectories: ['node_modules']
  },
  plugins: [
  ],
  module: {
    loaders: loaderConfigs,
    noParse: [
        /\.elm$/,
        /mermaid\/dist\/www\/javascripts\/lib\/mermaid.js/
    ]
  }
};
