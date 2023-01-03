module Stopwatch exposing
    ( Status
    , Stopwatch
    , init
    , lap
    , laps
    , lastLap
    , reset
    , start
    , stop
    , tick
    , view
    )

-- MODEL


type alias Stopwatch =
    { laps : List Float
    , delta : Float
    , status : Status
    }


type Status
    = Stopped
    | Running


init : Stopwatch
init =
    { laps = []
    , delta = 0
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
        | delta = 0
        , laps = []
    }


tick : Float -> Stopwatch -> Stopwatch
tick elapsedTime stopwatch =
    let
        elapseIfRuning : Float
        elapseIfRuning =
            case stopwatch.status of
                Stopped ->
                    stopwatch.delta

                Running ->
                    stopwatch.delta + elapsedTime
    in
    { stopwatch | delta = elapseIfRuning }


lap : Stopwatch -> Stopwatch
lap stopwatch =
    { stopwatch
        | laps =
            stopwatch.delta
                |> (\t -> t - lappedTime stopwatch)
                |> (\t -> t :: stopwatch.laps)
        , status = Running
    }


laps : Stopwatch -> List Float
laps stopwatch =
    List.reverse stopwatch.laps


lastLap : Stopwatch -> Float
lastLap stopwatch =
    stopwatch.laps
        |> List.head
        |> Maybe.withDefault 0



-- VIEW


view : Float -> String
view t =
    let
        secs : Int
        secs =
            modBy 60 (round t // 1000)

        mins : Int
        mins =
            floor t // 60000
    in
    addLeadingZero mins ++ ":" ++ addLeadingZero secs



-- PRIVATE FUNCTIONS


lappedTime : Stopwatch -> Float
lappedTime stopwatch =
    stopwatch.laps
        |> List.sum


addLeadingZero : Int -> String
addLeadingZero num =
    if num < 10 then
        "0" ++ String.fromInt num

    else
        String.fromInt num
