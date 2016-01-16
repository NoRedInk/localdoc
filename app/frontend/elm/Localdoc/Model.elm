module Localdoc.Model where


type alias Model =
    { authToken : String
    , allDocs : DocTree
    , filePath : String
    , savePath : String
    , editable : Bool
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
    , extension : String
    , rawContent : String
    , renderedContent : String
    , editing : Bool
    , saveState : SaveState
    }


type SaveState
    = Idle
    | Saving
    | SaveError
    | Saved
