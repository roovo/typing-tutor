module Stopwatch exposing (Stopwatch, elapsed, init, reset, start, stop, tick)

import Time exposing (Time)


type alias Stopwatch =
    { laps : List Time
    , elapsed : Clock
    }


type Clock
    = Stopped Time
    | Running Time


init : Stopwatch
init =
    { laps = []
    , elapsed = Stopped 0
    }


start : Stopwatch -> Stopwatch
start stopwatch =
    { stopwatch | elapsed = Running (elapsedTime stopwatch) }


stop : Stopwatch -> Stopwatch
stop stopwatch =
    { stopwatch | elapsed = Stopped (elapsedTime stopwatch) }


reset : Stopwatch -> Stopwatch
reset stopwatch =
    { stopwatch | elapsed = Stopped 0 }


tick : Time -> Stopwatch -> Stopwatch
tick time stopwatch =
    { stopwatch | elapsed = elapsedTick time stopwatch }


elapsed : Stopwatch -> Time
elapsed stopwatch =
    elapsedTime stopwatch



-- PRIVATE FUNCTIONS


elapsedTick : Time -> Stopwatch -> Clock
elapsedTick elapsedTime stopwatch =
    case stopwatch.elapsed of
        Stopped time ->
            stopwatch.elapsed

        Running time ->
            Running (time + elapsedTime)


elapsedTime : Stopwatch -> Time
elapsedTime stopwatch =
    case stopwatch.elapsed of
        Stopped time ->
            time

        Running time ->
            time
