port module Ports exposing
    ( keyDown
    , keyPress
    , scrollIfNearEdge
    )


port keyDown : (Int -> msg) -> Sub msg


port keyPress : (Int -> msg) -> Sub msg


port scrollIfNearEdge : Int -> Cmd msg
