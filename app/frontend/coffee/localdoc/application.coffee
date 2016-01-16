require "localdoc/application.sass"

Elm = require "Localdoc/API"
$ = require "jquery"

escapeHtml = (str) ->
    div = document.createElement('div')
    div.appendChild(document.createTextNode(str))
    div.innerHTML

$ ->
  pageData.authToken = $('meta[name="csrf-token"]').attr('content')

  app = Elm.embed Elm.Localdoc.API, document.getElementById("elm-host"),
    modelJson: pageData
    renderedContent: [-1, ""]

  app.ports.renderContent.subscribe ([sectionIndex, format, content]) ->
      rendered = "<pre><code>" + escapeHtml(content) + "</code></pre>"
      app.ports.renderedContent.send [sectionIndex, rendered]
