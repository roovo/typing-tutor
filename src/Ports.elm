port module Ports exposing
    ( keyDown
    , keyPress
    , scrollIfNearEdge
    )

import Attempt exposing (Attempt)
import Time exposing (Posix)


port keyDown : (Int -> msg) -> Sub msg


port keyPress : (Int -> msg) -> Sub msg


port scrollIfNearEdge : Int -> Cmd msg
