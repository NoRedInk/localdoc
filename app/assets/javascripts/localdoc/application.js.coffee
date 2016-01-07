#= require jquery/jquery
#= require Component/Dev/Docs/API

$ ->
  pageData.authToken = $('meta[name="csrf-token"]').attr('content')

  Elm.embed Elm.Component.Dev.Docs.API, document.getElementById("elm-host"),
    {modelJson: pageData}
