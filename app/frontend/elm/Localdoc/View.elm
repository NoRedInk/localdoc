module Localdoc.View where

import String
import Signal exposing (Address)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, targetValue, onClick)
import Html.Raw
import Markdown

import Localdoc.Update exposing (Action(..))
import Localdoc.Model exposing (Model, DocTree(..), DocTreeNode)
import Localdoc.Util exposing ((=>))


view : Address Action -> Model -> Html
view address model =
    div
      [ class "page-large" ]
      [ viewAllDocs model.allDocs
      , viewDoc address model
      ]


viewAllDocs : DocTree -> Html
viewAllDocs tree =
    case tree of
        DocTree nodes ->
            nav
              [ class "doctree" ]
              (viewDocTree nodes)


viewDocTree : List DocTreeNode -> List Html
viewDocTree nodes =
    let
        viewTopLevelDocTree node =
            [ h2
                []
                [ text node.name ]
            , ul
                [ class "doctree-toplevel-list" ]
                (viewChildren node.children)
            ]

        viewChildren : DocTree -> List Html
        viewChildren tree =
            case tree of
                DocTree nodes ->
                    List.map viewChild nodes

        viewChild : DocTreeNode -> Html
        viewChild child =
            let
                name =
                    case child.children of
                        DocTree grandChildren ->
                            case grandChildren of
                                [] ->
                                    a
                                      [ href child.url ]
                                      [ text child.name ]
                                _ ->
                                    text child.name
            in
                li
                  []
                  [ name
                  , ul
                    [ class "doctree-sublevel-list" ]
                    (viewChildren child.children)
                  ]

    in
        List.concatMap viewTopLevelDocTree nodes


viewDoc : Address Action -> Model -> Html
viewDoc address model =
    let
        header =
            [ h1
              [ class "doc-path" ]
              [ text model.filePath ]
            ]

        content =
            case model.blockingError of
                Just error ->
                    [ p [ class "blocking-error" ] [ text error ] ]

                Nothing ->
                    viewDocument address model
    in
        article
          [ class "doc" ]
          (header ++ content)


viewDocument : Address Action -> Model -> List Html
viewDocument address model =
    let
        body =
            viewBody address model

        docFooter =
            footer
              [ class "doc-footer" ]
              [ ul
                [ class "doc-footer-helps" ]
                editHelps
              ]
    in
        [ body
        , docFooter
        ]


editHelps : List Html
editHelps =
    [ "Editing a section title and adding new sections aren't supported: edit the doc directly with your editor."
    , "[Mermaid syntax](http://knsv.github.io/mermaid/index.html#flowcharts-basic-syntax)"
    ]
          |> List.map Markdown.toHtml
          |> List.map (\help -> li [] [ help ])


viewBody : Address Action -> Model -> Html
viewBody address model =
    let
        extensionSpecificClass =
            toString model.extension
                |> String.toLower
                |> (++) "doc-body-"

    in
        div
          [ classList
            [ "doc-body" => True
            , extensionSpecificClass => True
            ]
          ]
          [ viewRendered model
          , viewEditLink address model
          , viewEditor address model
          ]

viewRendered : Model -> Html
viewRendered model =
    Html.Raw.toHtml model.renderedContent


viewEditLink : Address Action -> Model -> Html
viewEditLink address model =
    let
        toggleText =
            if model.editing then
                "done"
            else
                "edit"
    in
      if model.editable then
          a
          [ class "doc-edit-link"
          , href "javascript:void(0)"
          , onClick address ToggleEditing
          ]
          [ text toggleText ]
      else
          span
          [ classList
            [ "doc-edit-link" => True
            , "disabled" => True
            ]
          ]
          [ text "(you can edit only in development)" ]


viewEditor : Address Action -> Model -> Html
viewEditor address model =
    let
        onInput address contentToValue =
            on "input" targetValue (\str -> Signal.message address (contentToValue str))
    in
        div
          [ classList
            [ "doc-editor" => True
            , "editing" => model.editing
            ]
          ]
          [ textarea
            [ class "doc-editor-content"
            , onInput address (HandleRawContentInput model.extension) ]
            [ text model.rawContent ]
          , footer
            [ class "doc-section-editor-footer" ]
            [ text (toString model.saveState) ]
          ]
