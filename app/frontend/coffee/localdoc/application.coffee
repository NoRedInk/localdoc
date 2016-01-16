require "localdoc/application.sass"
require "highlight.js/styles/github.css"

Elm = require "Localdoc/API"
$ = require "jquery"
markdown = require "localdoc/renderer/markdown"
extensionFormatMap = require "localdoc/extension_format_map.json"

$ ->
  pageData.model.authToken = $('meta[name="csrf-token"]').attr('content')

  app = Elm.embed Elm.Localdoc.API, document.getElementById("elm-host"),
    modelJson: pageData.model
    renderedContent: [-1, ""]

  md = markdown(pageData.markdownOptions)

  app.ports.renderContent.subscribe ([sectionIndex, extension, content]) ->
      extension = extension.toLowerCase()
      format = extensionFormatMap[extension] || extension
      # Render all formats through markdown for now.
      unless format == "markdown"
          content = require("./format/raw")(content, extension)
      rendered = md.render(content)

      app.ports.renderedContent.send [sectionIndex, rendered]
