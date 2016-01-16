module Localdoc.API where

import Task
import Json.Decode as Decode exposing (Value)
import Html exposing (div, text)
import Effects exposing (Never)
import StartApp
import StartApp.FromResult
import Signal.Time exposing (settledAfter)

import Localdoc.Model exposing (Model, Format(Markdown))
import Localdoc.Model.Decoder as ModelDecoder
import Localdoc.View exposing (view)
import Localdoc.Update exposing (Action(..), Addresses, update)
import Localdoc.Util exposing ((=>))


port modelJson : Value
port renderedContent : Signal (Int, String)


app : StartApp.App (Result String Model)
app =
    let
        decodedModelResult =
            modelJson
                |> Decode.decodeValue ModelDecoder.model
                |> Result.map toModelEffects

        toModelEffects model =
            let
                renderSection sectionIndex section =
                    Signal.send addresses.renderContent (sectionIndex, section.format, section.rawContent)
                          |> Task.map (always NoOp)
                          |> Effects.task

                effects =
                    model.sections
                         |> List.indexedMap renderSection
            in
              model => (Effects.batch effects)

        addresses =
            { sectionContentInput = sectionContentInputMailbox.address
            , renderContent = renderContentMailbox.address
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
              , renderedContent
                  |> Signal.map RenderedContent
              ]
            }


main =
    app.html


port tasks : Signal (Task.Task Never ())
port tasks =
    app.tasks


{-| Signal for (sectionIndex, format, rawContent).
JavaScript side should render rawContent as HTML and
send it to the `renderedContent` port.
-}
port renderContent : Signal (Int, String, String)
port renderContent =
    let
        mapper : (Int, Format, String) -> (Int, String, String)
        mapper (sectionIndex, format, content) =
            (sectionIndex, (toString format), content)
    in
      renderContentMailbox.signal
          |> Signal.map mapper


renderContentMailbox : Signal.Mailbox (Int, Format, String)
renderContentMailbox =
    Signal.mailbox (-1, Markdown, "")


{-| Mailbox for routing user input through `settledAfter`.
-}
sectionContentInputMailbox : Signal.Mailbox (Int, Format, String)
sectionContentInputMailbox =
    Signal.mailbox (-1, Markdown, "")
