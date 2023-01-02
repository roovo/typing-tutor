port module Ports exposing (keyDown, keyPress, scrollIfNearEdge)

import Attempt exposing (Attempt)
import Time exposing (Posix)


type alias ChartData =
    { completedAt : Posix
    , accuracy : Float
    , wpm : Float
    }


port keyDown : (Int -> msg) -> Sub msg


port keyPress : (Int -> msg) -> Sub msg



-- port chartAttempts : List ChartData -> Cmd msg


port scrollIfNearEdge : Int -> Cmd msg



-- showChart : List Attempt -> Cmd msg
-- showChart attempts =
--     let
--         toChartData =
--             \a ->
--                 { completedAt = a.completedAt
--                 , accuracy = a.accuracy
--                 , wpm = a.wpm
--                 }
--     in
--         List.map toChartData attempts
--             |> chartAttempts
