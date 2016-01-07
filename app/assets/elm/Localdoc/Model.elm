module Localdoc.Model where


type alias Model =
    { authToken : String
    , allDocs : DocTree
    , path : String
    , sections : List DocSection
    , blockingError : Maybe String
    }


type alias DocTreeNode =
    { name : String
    , url : String
    , children : DocTree
    }


type DocTree =
    DocTree (List DocTreeNode)


type alias DocSection =
    { title : String
    , format : Format
    , content : String
    , editing : Bool
    , saveState : SaveState
    }


type Format
    = Mermaid
    | Json
    | Markdown


type SaveState
    = Idle
    | Saving
    | SaveError
    | Saved
