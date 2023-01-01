module Stopwatch exposing
    ( Stopwatch
    , init
    , lap
    , laps
    , lastLap
    , reset
    , start
    , stop
    , tick
    , time
    , view
    )

import Time exposing (Posix)



-- MODEL


type alias Stopwatch =
    { laps : List Int
    , time : Int
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


tick : Int -> Stopwatch -> Stopwatch
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


time : Stopwatch -> Int
time stopwatch =
    stopwatch.time


lap : Stopwatch -> Stopwatch
lap stopwatch =
    { stopwatch
        | laps =
            stopwatch.time
                |> (\t -> t - lappedTime stopwatch)
                |> (\t -> t :: stopwatch.laps)
        , status = Running
    }


laps : Stopwatch -> List Int
laps stopwatch =
    List.reverse stopwatch.laps


lastLap : Stopwatch -> Int
lastLap stopwatch =
    stopwatch.laps
        |> List.head
        |> Maybe.withDefault 0



-- VIEW


view : Float -> String
view t =
    let
        secs =
            modBy 60 (round t // 1000)

        mins =
            floor t // 60000
    in
    addLeadingZero mins ++ ":" ++ addLeadingZero secs



-- PRIVATE FUNCTIONS


lappedTime : Stopwatch -> Int
lappedTime stopwatch =
    stopwatch.laps
        |> List.sum


addLeadingZero : Int -> String
addLeadingZero num =
    if num < 10 then
        "0" ++ String.fromInt num

    else
        String.fromInt num
