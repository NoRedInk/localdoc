$ = require "jquery"
md = require 'markdown-it'
hljs = require 'highlight.js'
mermaid = require './markdown/mermaid'

highlight = (str, lang) ->
    if lang && hljs.getLanguage(lang)
        try
            return hljs.highlight(lang, str).value
        catch

    return '' # use external default escaping

mdOptions =
    html: true
    breaks: true
    linkify: true
    highlight: highlight

module.exports = (options) ->
    md($.extend({}, mdOptions, options))
        .use(require('markdown-it-container'), 'mermaid', mermaid(options?.mermaid))
