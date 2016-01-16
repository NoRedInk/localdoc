module Localdoc.View where

import String
import Signal exposing (Address)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on, targetValue, onClick)
import Html.Raw
import Markdown

import Localdoc.Update exposing (Action(..))
import Localdoc.Model exposing (Model, DocTree(..), DocTreeNode, DocSection, Format(..))
import Localdoc.Util exposing ((=>))


view : Address Action -> Model -> Html
view address model =
    nav
      [ class "page-large" ]
      [ viewAllDocs model.allDocs
      , viewDoc address model
      ]


viewAllDocs : DocTree -> Html
viewAllDocs tree =
    case tree of
        DocTree nodes ->
            div
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
              [ text model.path ]
            ]

        content =
            case model.blockingError of
                Just error ->
                    [ p [ class "blocking-error" ] [ text error ] ]

                Nothing ->
                    viewSections address model.sections
    in
        article
          [ class "doc" ]
          (header ++ content)


viewSections : Address Action -> List DocSection -> List Html
viewSections address sections =
    let
        body =
            List.indexedMap (viewSection address) sections
                |> List.concat

        sectionIsEditable section =
            case section.format of
                Mermaid -> True
                _ -> False

        editHelps =
            [ "Editing a section title and adding new sections aren't supported: edit the doc directly with your editor."
            , "[Mermaid syntax](http://knsv.github.io/mermaid/index.html#flowcharts-basic-syntax)"
            ]
            |> List.map Markdown.toHtml
            |> List.map (\help -> li [] [ help ])

        docFooter =
            if List.any sectionIsEditable sections then
                [ footer
                  [ class "doc-footer" ]
                  [ ul
                    [ class "doc-footer-helps" ]
                    editHelps
                  ]
                ]
            else
                []
    in
        body ++ docFooter


viewSection : Address Action -> Int -> DocSection -> List Html
viewSection address sectionIndex docSection =
    let
        header =
            h2
              [ class "doc-section-title" ]
              [ text docSection.title ]

        content =
            viewSectionContent address sectionIndex docSection

        formatSpecificClass =
            toString docSection.format
                |> String.toLower
                |> (++) "doc-section-content-"
    in
        [ header
        , div
            [ classList
                [ "doc-section-content" => True
                , formatSpecificClass => True
                ]
            ]
            content
        ]


viewSectionContent : Address Action -> Int -> DocSection -> List Html
viewSectionContent address sectionIndex section =
    let
        content =
            Html.Raw.toHtml section.renderedContent

        onInput address contentToValue =
            on "input" targetValue (\str -> Signal.message address (contentToValue str))

        editor =
            div
              [ classList
                [ "doc-section-editor" => True
                , "editing" => section.editing
                ]
              ]
              [ textarea
                [ class "doc-section-editor-content"
                , onInput address (HandleSectionContentInput sectionIndex section.format) ]
                [ text section.rawContent ]
              , footer
                [ class "doc-section-editor-footer" ]
                [ text (toString section.saveState) ]
              ]

        toggleText =
            if section.editing then
                "done"
            else
                "edit"
    in
        [ content
        , a
          [ href "javascript:void(0)"
          , onClick address (ToggleSectionEditing sectionIndex)
          ]
          [ text toggleText ]
        , editor
        ]
