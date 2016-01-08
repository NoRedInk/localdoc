Elm = require "Localdoc/API"
$ = require "jquery"

$ ->
  pageData.authToken = $('meta[name="csrf-token"]').attr('content')

  Elm.embed Elm.Localdoc.API, document.getElementById("elm-host"),
    modelJson: pageData
