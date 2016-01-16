module Localdoc.Model where


type alias Model =
    { authToken : String
    , allDocs : DocTree
    , filePath : String
    , savePath : String
    , editable : Bool
    , extension : String
    , rawContent : String
    , renderedContent : String
    , editing : Bool
    , saveState : SaveState
    , blockingError : Maybe String
    }


type alias DocTreeNode =
    { name : String
    , url : String
    , children : DocTree
    }


type DocTree =
    DocTree (List DocTreeNode)


type SaveState
    = Idle
    | Saving
    | SaveError
    | Saved
