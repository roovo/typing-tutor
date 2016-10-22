module Stopwatch exposing (Stopwatch, init, lap, laps, lastLap, reset, start, stop, tick, time)

import Time exposing (Time)


type alias Stopwatch =
    { laps : List Time
    , time : Time
    , status : Status
    }


type Status
    = Stopped
    | Running


init : Stopwatch
init =
    { laps = []
    , time = 0
    , status = Stopped
    }


start : Stopwatch -> Stopwatch
start stopwatch =
    { stopwatch | status = Running }


stop : Stopwatch -> Stopwatch
stop stopwatch =
    { stopwatch | status = Stopped }


reset : Stopwatch -> Stopwatch
reset stopwatch =
    { stopwatch
        | time = 0
        , laps = []
    }


tick : Time -> Stopwatch -> Stopwatch
tick elapsedTime stopwatch =
    let
        elapseIfRuning =
            case stopwatch.status of
                Stopped ->
                    stopwatch.time

                Running ->
                    stopwatch.time + elapsedTime
    in
        { stopwatch | time = elapseIfRuning }


time : Stopwatch -> Time
time stopwatch =
    stopwatch.time


lap : Stopwatch -> Stopwatch
lap stopwatch =
    { stopwatch
        | laps =
            stopwatch.time
                |> (flip (-) (lappedTime stopwatch))
                |> (flip (::) stopwatch.laps)
        , status = Running
    }


laps : Stopwatch -> List Time
laps stopwatch =
    List.reverse stopwatch.laps


lastLap : Stopwatch -> Time
lastLap stopwatch =
    stopwatch.laps
        |> List.head
        |> Maybe.withDefault 0



-- PRIVATE FUNCTIONS


lappedTime : Stopwatch -> Time
lappedTime stopwatch =
    stopwatch.laps
        |> List.sum
