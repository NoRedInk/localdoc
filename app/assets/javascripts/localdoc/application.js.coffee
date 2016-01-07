#= require jquery/jquery
#= require Localdoc/API

$ ->
  pageData.authToken = $('meta[name="csrf-token"]').attr('content')

  Elm.embed Elm.Localdoc.API, document.getElementById("elm-host"),
    {modelJson: pageData}
