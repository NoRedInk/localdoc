module Html.Raw (toHtml) where

{-| Inner HTML.
-}

import Html exposing (Html)
import Native.RawHtml


{-|
-}
toHtml : String -> Html
toHtml =
    Native.RawHtml.toHtml
