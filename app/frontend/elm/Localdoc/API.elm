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
port renderedContent : Signal String


app : StartApp.App (Result String Model)
app =
    let
        decodedModelResult =
            modelJson
                |> Decode.decodeValue ModelDecoder.model
                |> Result.map toModelEffects

        toModelEffects model =
            let
                effects =
                    Signal.send addresses.renderContent (model.extension, model.rawContent)
                          |> Task.map (always NoOp)
                          |> Effects.task
            in
                model => effects

        addresses =
            { rawContentInput = contentInputMailbox.address
            , renderContent = renderContentMailbox.address
            }
    in
        StartApp.FromResult.start <|
            { init = decodedModelResult
            , update = update addresses
            , viewSuccess = view
            , viewError = (\error -> div [] [text error])
            , inputs =
              [ settledAfter 200 contentInputMailbox.signal
                  |> Signal.map UpdateRawContent
              , renderedContent
                  |> Signal.map RenderedContent
              ]
            }


main =
    app.html


port tasks : Signal (Task.Task Never ())
port tasks =
    app.tasks


{-| Signal for (extension, rawContent).
JavaScript side should render rawContent as HTML and
send it to the `renderedContent` port.
-}
port renderContent : Signal (String, String)
port renderContent =
    renderContentMailbox.signal


renderContentMailbox : Signal.Mailbox (String, String)
renderContentMailbox =
    Signal.mailbox ("", "")


{-| Mailbox for routing user input through `settledAfter`.
-}
contentInputMailbox : Signal.Mailbox (String, String)
contentInputMailbox =
    Signal.mailbox ("", "")
