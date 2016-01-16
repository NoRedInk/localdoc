module Localdoc.Update where

import Signal
import Task
import Json.Decode as Decode
import Json.Encode as Encode
import Effects exposing (Effects, Never)
import Http
import Rails

import Localdoc.Util exposing ((=>))
import Localdoc.Model exposing (Model, SaveState(..))


type Action
    = NoOp
    | HandleRawContentInput String String
    | UpdateRawContent (String, String)
    | SaveResponse (Result (Rails.Error ()) ())
    | ToggleEditing
    | RenderedContent String


type alias Addresses =
    { rawContentInput : Signal.Address (String, String)
    , renderContent : Signal.Address (String, String)
    }


update : Addresses -> Action -> Model -> (Model, Effects Action)
update addresses action model =
    case action of
        NoOp ->
            model => Effects.none

        HandleRawContentInput extension content ->
            let
                task =
                    Signal.send addresses.rawContentInput (extension, content)
                        |> Task.map (always NoOp)
            in
                model => Effects.task task

        UpdateRawContent (extension, content) ->
            let
                effects =
                    [ (saveDoc model)
                    , (Signal.send addresses.renderContent (extension, content))
                        |> Task.map (always NoOp)
                    ]
                        |> List.map Effects.task
            in
              { model
                  | rawContent = content
                  , saveState = Saving
              } => Effects.batch effects

        SaveResponse railsResponse ->
            let
                saveState =
                    case railsResponse of
                        Ok _ -> Saved
                        Err _ -> SaveError
            in
              { model
                    | saveState = saveState
              } => Effects.none

        ToggleEditing ->
            { model
                  | editing = not model.editing
            } => Effects.none

        RenderedContent content ->
            { model
                  | renderedContent = content
            } => Effects.none

saveDoc : Model -> Task.Task Never Action
saveDoc model =
    let
        jsonData =
            Encode.object
                [ "extension" => Encode.string (toString model.extension)
                , "rawContent" => Encode.string model.rawContent
                ]

        encodeBody jsonData =
            Http.string (Encode.encode 0 jsonData)
    in
        Rails.send model.authToken "PUT" model.savePath (encodeBody jsonData)
            |> Rails.fromJson (Rails.always (Decode.succeed ()))
            |> Task.toResult
            |> Task.map SaveResponse
