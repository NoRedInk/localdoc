module Localdoc.Util ((=>), (|:)) where
{-|
@docs (|:), (=>)
-}

import Json.Decode.Extra exposing (apply)


{-|
-}
(|:) = Json.Decode.Extra.apply


{-|
-}
(=>) : a -> b -> (a, b)
(=>) = (,)
