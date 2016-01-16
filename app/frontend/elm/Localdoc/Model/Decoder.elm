module Localdoc.Model.Decoder where

import Json.Decode exposing (..)

import Localdoc.Model exposing (Model, DocTree(..), DocTreeNode, DocSection, SaveState(Idle))
import Localdoc.Util exposing ((|:))


model : Decoder Model
model =
    succeed Model
        |: ("authToken" := string)
        |: ("allDocs" := docTree)
        |: ("filePath" := string)
        |: ("savePath" := string)
        |: ("editable" := bool)
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
        |: ("extension" := string)
        |: ("rawContent" := string)
        |: (succeed initialRenderedContent)
        |: (succeed False)
        |: (succeed Idle)


initialRenderedContent : String
initialRenderedContent =
    "rendering..."


lazy : (() -> Decoder a) -> Decoder a
lazy thunk =
  Json.Decode.customDecoder value
      (\js -> Json.Decode.decodeValue (thunk ()) js)
