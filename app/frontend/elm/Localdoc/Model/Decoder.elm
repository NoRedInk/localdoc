module Localdoc.Model.Decoder where

import Json.Decode exposing (..)

import Localdoc.Model exposing (Model, DocTree(..), DocTreeNode, DocSection, Format(..), SaveState(Idle))
import Localdoc.Util exposing ((|:))


model : Decoder Model
model =
    succeed Model
        |: ("authToken" := string)
        |: ("allDocs" := docTree)
        |: ("path" := string)
        |: ("sections" := list docSection)
        |: ("blockingError" := maybe string)


docTree : Decoder DocTree
docTree =
    list (lazy (\_ -> docTreeNode)) `andThen` (succeed << DocTree)


docTreeNode : Decoder DocTreeNode
docTreeNode =
    succeed DocTreeNode
        |: ("name" := string)
        |: ("url" := string)
        |: ("children" := docTree)


docSection : Decoder DocSection
docSection =
    succeed DocSection
        |: ("title" := string)
        |: ("format" := format)
        |: ("content" := string)
        |: (succeed False)
        |: (succeed Idle)


format : Decoder Format
format =
    let
        formatFromString str =
            case str of
                "mermaid" ->
                    succeed Mermaid
                "json" ->
                    succeed Json
                "md" ->
                    succeed Markdown
                _ ->
                    succeed Markdown
    in
        string `andThen` formatFromString


lazy : (() -> Decoder a) -> Decoder a
lazy thunk =
  Json.Decode.customDecoder value
      (\js -> Json.Decode.decodeValue (thunk ()) js)
