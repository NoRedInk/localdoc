// setup
Elm.Native = Elm.Native || {};
Elm.Native.Mermaid = Elm.Native.Mermaid || {};

// definition
Elm.Native.Mermaid.make = function(localRuntime) {
  'use strict';

  if ('values' in Elm.Native.Mermaid) {
    return Elm.Native.Mermaid.values;
  }

  var tempId = 0;

  function nextId() {
    return "mermaid" + tempId++;
  }

  function sanitizeOptions(options) {
    var stripProperties = function(obj) {
      var stripped = {};
      Object.keys(obj).forEach(function(key) {
        var value = obj[key];
        if (value.ctor === 'Nothing') {
          return;
        }
        if (typeof value._0 === 'object') {
          stripped[key] = stripProperties(value._0);
        } else {
          stripped[key] = value._0;
        }
      });
      return stripped;
    };
    return stripProperties(options);
  }

  function toHtmlWith(options, rawDiagram) {
    return new MermaidWidget(options, rawDiagram);
  }

  function MermaidWidget(options, rawDiagram) {
    this.options = options;
    this.diagram = rawDiagram;
  }

  MermaidWidget.prototype.type = "Widget";

  MermaidWidget.prototype.init = function init() {
    var node = document.createElement('div');
    renderDiagram(this.diagram, node, this.options);
    return node;
  };

  MermaidWidget.prototype.update = function update(previous, node) {
    if (this.diagram !== previous.diagram || this.options != previous.options) {
      renderDiagram(this.diagram, node, this.options);
    }
    return node;
  }

  function renderDiagram(source, node, options) {
    var sanitizedOptions = sanitizeOptions(options);
    sanitizedOptions.startOnLoad = false;
    mermaidAPI.initialize(sanitizedOptions);
    var error;
    mermaidAPI.parseError = function(e, hash) {
      error = e;
    };
    var html = mermaidAPI.render(nextId(), source);
    if (typeof html === 'undefined') {
      var message;
      if (typeof error !== 'undefined') {
        message = error;
      } else {
        message = "Sorry, `mermaidAPI.render` returned `undefined` and `parseError` hasn't received any errors either.";
      }
      html = '<pre>' + message + '</pre>';
    }
    node.innerHTML = html;
  }

  return Elm.Native.Mermaid.values = {
    toHtmlWith: F2(toHtmlWith)
  };
};
