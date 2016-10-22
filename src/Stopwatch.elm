module Stopwatch exposing (Stopwatch, elapsed, init, lap, laps, reset, start, stop, tick)

import Time exposing (Time)


type alias Stopwatch =
    { laps : List Time
    , elapsed : Time
    , status : Status
    }


type Status
    = Stopped
    | Running


init : Stopwatch
init =
    { laps = []
    , elapsed = 0
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
      | elapsed = 0
      , laps = []
    }


tick : Time -> Stopwatch -> Stopwatch
tick elapsedTime stopwatch =
    let
        elapseIfRuning =
            case stopwatch.status of
                Stopped ->
                    stopwatch.elapsed

                Running ->
                    stopwatch.elapsed + elapsedTime
    in
        { stopwatch | elapsed = elapseIfRuning }


elapsed : Stopwatch -> Time
elapsed stopwatch =
    stopwatch.elapsed


lap : Stopwatch -> Stopwatch
lap stopwatch =
    let
        addLapIfRunning =
            case stopwatch.status of
                Stopped ->
                    stopwatch.laps

                Running ->
                    stopwatch.elapsed
                        |> (flip (-) (lappedTime stopwatch))
                        |> (flip (::) stopwatch.laps)

    in
        { stopwatch | laps = addLapIfRunning }


laps : Stopwatch -> List Time
laps stopwatch =
    List.reverse stopwatch.laps


lappedTime : Stopwatch -> Time
lappedTime stopwatch =
    stopwatch.laps
        |> List.sum
