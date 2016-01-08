module Localdoc.API where

import Task
import Json.Decode as Decode exposing (Value)
import Html exposing (div, text)
import Effects exposing (Never)
import StartApp
import StartApp.FromResult
import Signal.Time exposing (settledAfter)

import Localdoc.Model exposing (Model)
import Localdoc.Model.Decoder as ModelDecoder
import Localdoc.View exposing (view)
import Localdoc.Update exposing (Action(..), Addresses, update)
import Localdoc.Util exposing ((=>))


port modelJson : Value


app : StartApp.App (Result String Model)
app =
    let
        decodedModelResult =
            modelJson
                |> Decode.decodeValue ModelDecoder.model
                |> Result.map (\model -> (model => Effects.none))

        addresses =
            { sectionContentInput = sectionContentInputMailbox.address
            }
    in
        StartApp.FromResult.start <|
            { init = decodedModelResult
            , update = update addresses
            , viewSuccess = view
            , viewError = (\error -> div [] [text error])
            , inputs =
              [ settledAfter 200 sectionContentInputMailbox.signal
                  |> Signal.map UpdateSectionContent
              ]
            }


main =
    app.html


port tasks : Signal (Task.Task Never ())
port tasks =
    app.tasks


sectionContentInputMailbox : Signal.Mailbox (Int, String)
sectionContentInputMailbox =
    Signal.mailbox (-1, "")
