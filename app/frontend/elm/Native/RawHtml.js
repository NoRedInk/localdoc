// setup
Elm.Native = Elm.Native || {};
Elm.Native.RawHtml = Elm.Native.RawHtml || {};

// definition
Elm.Native.RawHtml.make = function(localRuntime) {
  'use strict';

  if ('values' in Elm.Native.RawHtml) {
    return Elm.Native.RawHtml.values;
  }

  function toHtml(rawSource) {
    return new RawHtmlWidget(rawSource);
  }

  function RawHtmlWidget(rawSource) {
    this.source = rawSource;
  }

  RawHtmlWidget.prototype.type = "Widget";

  RawHtmlWidget.prototype.init = function init() {
    var node = document.createElement('div');
    node.innerHTML = this.source;
    return node;
  };

  RawHtmlWidget.prototype.update = function update(previous, node) {
    if (this.source !== previous.source) {
      node.innerHTML = this.source;
    }
    return node;
  }

  return Elm.Native.RawHtml.values = {
    toHtml: toHtml
  };
};
