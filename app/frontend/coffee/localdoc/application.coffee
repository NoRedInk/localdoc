require "localdoc/application.sass"
require "highlight.js/styles/github.css"

Elm = require "Localdoc/API"
$ = require "jquery"
markdown = require "localdoc/renderer/markdown"
extensionFormatMap = require "localdoc/extension_format_map.json"

$ ->
  pageData.model.authToken = $('meta[name="csrf-token"]').attr('content') || 'dummyToken'

  app = Elm.embed Elm.Localdoc.API, document.getElementById("elm-host"),
    modelJson: pageData.model
    renderedContent: ""

  md = markdown(pageData.markdownOptions)

  app.ports.renderContent.subscribe ([extension, content]) ->
      extension = extension.toLowerCase()
      format = extensionFormatMap[extension] || extension
      # Render all formats through markdown for now.
      unless format == "markdown"
          content = require("./formatter/raw")(content, format)
      rendered = md.render(content)

      app.ports.renderedContent.send rendered
