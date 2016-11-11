port module Ports exposing (keyDown, keyPress, showChart)

import Attempt exposing (Attempt)
import Keyboard exposing (KeyCode)
import Time exposing (Time)


type alias ChartData =
    { completedAt : Time
    , accuracy : Float
    , wpm : Float
    }


port keyDown : (KeyCode -> msg) -> Sub msg


port keyPress : (KeyCode -> msg) -> Sub msg


port chartAttempts : List ChartData -> Cmd msg


showChart : List Attempt -> Cmd msg
showChart attempts =
    let
        toChartData =
            \a ->
                { completedAt = a.completedAt
                , accuracy = a.accuracy
                , wpm = a.wpm
                }
    in
        List.map toChartData attempts
            |> chartAttempts
