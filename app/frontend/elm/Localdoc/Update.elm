module Localdoc.Update where

import Signal
import Task
import Json.Decode as Decode
import Json.Encode as Encode
import Effects exposing (Effects, Never)
import Http
import Rails

import Localdoc.Util exposing ((=>))
import Localdoc.Model exposing (Model, DocSection, Format, SaveState(..))


type Action
    = NoOp
    | HandleSectionContentInput Int Format String
    | UpdateSectionContent (Int, Format, String)
    | SaveSectionResponse Int (Result (Rails.Error ()) ())
    | ToggleSectionEditing Int
    | RenderedContent (Int, String)


type alias Addresses =
    { sectionContentInput : Signal.Address (Int, Format, String)
    , renderContent : Signal.Address (Int, Format, String)
    }


update : Addresses -> Action -> Model -> (Model, Effects Action)
update addresses action model =
    case action of
        NoOp ->
            model => Effects.none

        HandleSectionContentInput sectionIndex format content ->
            let
                task =
                    Signal.send addresses.sectionContentInput (sectionIndex, format, content)
                        |> Task.map (always NoOp)
            in
                model => Effects.task task

        UpdateSectionContent (sectionIndex, format, content) ->
            let
                updateSection section =
                    { section
                         | rawContent = content
                         , saveState = Saving
                    }

                newModel =
                    updateModelSection updateSection sectionIndex model

                effects =
                    [ (saveDoc model sectionIndex)
                    , (Signal.send addresses.renderContent (sectionIndex, format, content))
                        |> Task.map (always NoOp)
                    ]
                        |> List.map Effects.task
            in
                newModel => Effects.batch effects

        SaveSectionResponse sectionIndex railsResponse ->
            let
                saveState =
                    case railsResponse of
                        Ok _ -> Saved
                        Err _ -> SaveError

                updater section =
                    { section | saveState = saveState }

                newModel =
                    updateModelSection updater sectionIndex model
            in
                newModel => Effects.none

        ToggleSectionEditing sectionIndex ->
            let
                updater section =
                    { section | editing = not section.editing }

                newModel =
                    updateModelSection updater sectionIndex model
            in
                newModel => Effects.none

        RenderedContent (sectionIndex, content) ->
            let
                updater section =
                    { section | renderedContent = content }

                newModel =
                    updateModelSection updater sectionIndex model
            in
                newModel => Effects.none


updateModelSection : (DocSection -> DocSection) -> Int -> Model -> Model
updateModelSection updater sectionIndex model =
    let
        eachSection thisIndex section =
            if thisIndex == sectionIndex then
                updater section
            else
                section
    in
        { model
             | sections = List.indexedMap eachSection model.sections
        }


saveDoc : Model -> Int -> Task.Task Never Action
saveDoc model sectionIndex =
    let
        encodeSection section =
            Encode.object
                [ "title" => Encode.string section.title
                , "format" => Encode.string (toString section.format)
                , "content" => Encode.string section.rawContent
                ]

        jsonData =
            Encode.object
                [ "sections" => Encode.list (List.map encodeSection model.sections) ]

        encodeBody jsonData =
            Http.string (Encode.encode 0 jsonData)


        url =
            saveDocPath model
    in
        Rails.send model.authToken "PUT" url (encodeBody jsonData)
            |> Rails.fromJson (Rails.always (Decode.succeed ()))
            |> Task.toResult
            |> Task.map (SaveSectionResponse sectionIndex)


-- FIXME: pass routing information from the rails side
saveDocPath : Model -> String
saveDocPath model =
    "/dev/docs/" ++ model.path
