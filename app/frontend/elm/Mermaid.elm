module Mermaid where
{-| Wrapper for [Mermaid](http://knsv.github.io/mermaid/).

Expects `mermaidAPI` object to be available globally.

    = javascript_include_tag "https://cdn.rawgit.com/knsv/mermaid/0.5.6/dist/mermaidAPI.min.js"
    = stylesheet_link_tag "https://cdn.rawgit.com/knsv/mermaid/0.5.6/dist/mermaid.forest.css"

# Parsing Mermaid
@docs toHtml

# Parsing with Custom Options
@docs Options, FlowchartOptions, SequnceDiagramOptions, GanttOptions, debug, info, warn, error, fatal, defaultOptions, toHtmlWith
-}

import Html exposing (Html)
import Native.Mermaid


{-| Turn a Mermaid graph definition into an HTML element, using the `defaultOptions`.

    sequenceDiagram : Html
    sequenceDiagram =
        Mermaid.toHtml """

    sequenceDiagram
    A->> B: Query
    B->> C: Forward query
    Note right of C: Thinking...
    C->> B: Response
    B->> A: Forward response
    """
-}
toHtml : String -> Html
toHtml string =
    Native.Mermaid.toHtmlWith defaultOptions string


{-| Mermaid options. See [Mermaid API](http://knsv.github.io/mermaid/index.html#mermaidapi) for details.
-}
type alias Options =
    { logLevel : Maybe Int
    , cloneCssStyles : Maybe Bool
    , arrowMarkerAbsolute : Maybe Bool
    , flowchart : Maybe FlowchartOptions
    , sequenceDiagram : Maybe SequenceDiagramOptions
    , gantt : Maybe GanttOptions
    }


{-| Default options.
-}
defaultOptions : Options
defaultOptions =
    { logLevel = Nothing
    , cloneCssStyles = Nothing
    , arrowMarkerAbsolute = Nothing
    , flowchart = Just defaultFlowchartOptions
    , sequenceDiagram = Just defaultSequenceDiagramOptions
    , gantt = Just defaultGanttOptions
    }


debug : Maybe Int
debug = Just 1

info : Maybe Int
info = Just 2

warn : Maybe Int
warn = Just 3

error : Maybe Int
error = Just 4

fatal : Maybe Int
fatal = Just 5


{-| Options for flowcharts.
-}
type alias FlowchartOptions =
    { htmlLabels : Maybe Bool
    , useMaxWidth : Maybe Bool
    }


{-| Default flowchart options.
-}
defaultFlowchartOptions =
    { htmlLabels = Nothing
    , useMaxWidth = Nothing
    }


{-| Options for sequence diagrams.
-}
type alias SequenceDiagramOptions =
    { diagramMarginX : Maybe Int
    , diagramMarginY : Maybe Int
    , actorMargin : Maybe Int
    , width : Maybe Int
    , height : Maybe Int
    , boxMargin : Maybe Int
    , boxTextMargin : Maybe Int
    , noteMargin : Maybe Int
    , messageMargin : Maybe Int
    , mirrorActors : Maybe Bool
    , bottomMarginAdj : Maybe Int
    , useMaxWidth : Maybe Bool
    }


{-| Default sequence diagram options.
-}
defaultSequenceDiagramOptions : SequenceDiagramOptions
defaultSequenceDiagramOptions =
    { diagramMarginX = Nothing
    , diagramMarginY = Nothing
    , actorMargin = Nothing
    , width = Nothing
    , height = Nothing
    , boxMargin = Nothing
    , boxTextMargin = Nothing
    , noteMargin = Nothing
    , messageMargin = Nothing
    , mirrorActors = Nothing
    , bottomMarginAdj = Nothing
    , useMaxWidth = Nothing
    }


{-| Options for gantt diagrams. `axisFormatter` is unsupported.
-}
type alias GanttOptions =
    { titleTopMargin : Maybe Int
    , barHeight : Maybe Int
    , barGap : Maybe Int
    , topPadding : Maybe Int
    , sidePadding : Maybe Int
    , gridLineStartPadding : Maybe Int
    , fontSize : Maybe Int
    , fontFamily : Maybe String
    , numberSectionStyles : Maybe Int
    }


{-| Default gantt options.
-}
defaultGanttOptions : GanttOptions
defaultGanttOptions =
    { titleTopMargin = Nothing
    , barHeight = Nothing
    , barGap = Nothing
    , topPadding = Nothing
    , sidePadding = Nothing
    , gridLineStartPadding = Nothing
    , fontSize = Nothing
    , fontFamily = Nothing
    , numberSectionStyles = Nothing
    }
