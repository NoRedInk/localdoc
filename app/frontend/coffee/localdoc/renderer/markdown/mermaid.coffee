require('mermaid/dist/www/stylesheets/mermaid.forest.css')

$ = require "jquery"
mermaidAPI = require('mermaid/dist/www/javascripts/lib/mermaid').mermaidAPI

tempId = 0

nextId = ->
    "mermaid" + tempId++

contentRenderer = (tokens, idx) ->
    renderDiagram(tokens[idx].markup)

renderDiagram = (source) ->
    error = html = null

    mermaidAPI.parseError = (e, hash) ->
        error = e

    try
        mermaidAPI.render nextId(), source.trim(), (svgCode) ->
            html = svgCode
    catch e
        error = e

    if typeof html == 'undefined'
        message = error || "Sorry, `mermaidAPI.render` returned `undefined` and `parseError` hasn't received any errors either."
        html = "<pre>#{message}</pre>"

    return html

module.exports = (options) ->
    mermaidAPI.initialize($.extend({}, options, {startOnLoad: false}))

    content: contentRenderer
