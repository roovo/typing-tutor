module StopwatchTests exposing (all)

import Stopwatch exposing (Stopwatch)
import Expect
import Test exposing (..)


all : Test
all =
    describe "Stopwatch"
        [ basicOperationTests
        , lapTimerTests
        , viewTests
        ]


basicOperationTests : Test
basicOperationTests =
    describe "basic operation"
        [ test "has a time of zero if not started" <|
            \() ->
                Stopwatch.init
                    |> Stopwatch.tick 1000
                    |> Stopwatch.time
                    |> Expect.equal 0
        , test "has a time of total ticks since started" <|
            \() ->
                Stopwatch.init
                    |> Stopwatch.tick 1000
                    |> Stopwatch.start
                    |> Stopwatch.tick 53
                    |> Stopwatch.tick 10
                    |> Stopwatch.time
                    |> Expect.equal 63
        , test "starting when already started has no effect" <|
            \() ->
                Stopwatch.init
                    |> Stopwatch.tick 1000
                    |> Stopwatch.start
                    |> Stopwatch.tick 53
                    |> Stopwatch.start
                    |> Stopwatch.tick 10
                    |> Stopwatch.start
                    |> Stopwatch.time
                    |> Expect.equal 63
        , test "can be stopped" <|
            \() ->
                Stopwatch.init
                    |> Stopwatch.tick 1000
                    |> Stopwatch.start
                    |> Stopwatch.tick 53
                    |> Stopwatch.stop
                    |> Stopwatch.tick 10
                    |> Stopwatch.time
                    |> Expect.equal 53
        , test "can be restarted" <|
            \() ->
                Stopwatch.init
                    |> Stopwatch.tick 1000
                    |> Stopwatch.start
                    |> Stopwatch.tick 53
                    |> Stopwatch.stop
                    |> Stopwatch.start
                    |> Stopwatch.tick 10
                    |> Stopwatch.time
                    |> Expect.equal 63
        , test "can be reset" <|
            \() ->
                Stopwatch.init
                    |> Stopwatch.tick 1000
                    |> Stopwatch.start
                    |> Stopwatch.tick 53
                    |> Stopwatch.stop
                    |> Stopwatch.reset
                    |> Stopwatch.start
                    |> Stopwatch.tick 10
                    |> Stopwatch.time
                    |> Expect.equal 10
        ]


lapTimerTests : Test
lapTimerTests =
    describe "lap timer"
        [ test "no laps if lap timer not used" <|
            \() ->
                Stopwatch.init
                    |> Stopwatch.tick 1000
                    |> Stopwatch.start
                    |> Stopwatch.tick 53
                    |> Stopwatch.tick 10
                    |> Stopwatch.laps
                    |> Expect.equal []
        , test "saves lap times when used" <|
            \() ->
                Stopwatch.init
                    |> Stopwatch.tick 1000
                    |> Stopwatch.start
                    |> Stopwatch.tick 53
                    |> Stopwatch.lap
                    |> Stopwatch.tick 10
                    |> Stopwatch.tick 10
                    |> Stopwatch.lap
                    |> Stopwatch.tick 42
                    |> Stopwatch.lap
                    |> Stopwatch.laps
                    |> Expect.equal [ 53, 20, 42 ]
        , test "auto-starts if not running" <|
            \() ->
                Stopwatch.init
                    |> Stopwatch.tick 1000
                    |> Stopwatch.lap
                    |> Stopwatch.tick 53
                    |> Stopwatch.lap
                    |> Stopwatch.tick 10
                    |> Stopwatch.lap
                    |> Stopwatch.laps
                    |> Expect.equal [ 0, 53, 10 ]
        , test "reset clears lap times" <|
            \() ->
                Stopwatch.init
                    |> Stopwatch.tick 1000
                    |> Stopwatch.start
                    |> Stopwatch.tick 53
                    |> Stopwatch.lap
                    |> Stopwatch.tick 10
                    |> Stopwatch.reset
                    |> Stopwatch.tick 10
                    |> Stopwatch.lap
                    |> Stopwatch.tick 42
                    |> Stopwatch.lap
                    |> Stopwatch.laps
                    |> Expect.equal [ 10, 42 ]
        , test "returns 0 as lastLap if there are no laps" <|
            \() ->
                Stopwatch.init
                    |> Stopwatch.tick 1000
                    |> Stopwatch.start
                    |> Stopwatch.tick 53
                    |> Stopwatch.lastLap
                    |> Expect.equal 0
        , test "returns the lastLap if there are laps" <|
            \() ->
                Stopwatch.init
                    |> Stopwatch.tick 1000
                    |> Stopwatch.start
                    |> Stopwatch.tick 53
                    |> Stopwatch.lap
                    |> Stopwatch.tick 10
                    |> Stopwatch.lap
                    |> Stopwatch.lastLap
                    |> Expect.equal 10
        ]


viewTests : Test
viewTests =
    describe "view"
        [ test "is 00:00 if there is no time" <|
            \() ->
                Stopwatch.view 0
                    |> Expect.equal "00:00"
        , test "is 00:04 if the time is 4748.97312" <|
            \() ->
                Stopwatch.view 4748
                    |> Expect.equal "00:04"
        , test "is 00:59 if the time is 59999" <|
            \() ->
                Stopwatch.view 59999
                    |> Expect.equal "00:59"
        , test "is 01:00 if the time is 60000" <|
            \() ->
                Stopwatch.view 60000
                    |> Expect.equal "01:00"
        , test "is 02:04 if the time is 124748.97312" <|
            \() ->
                Stopwatch.view 124748
                    |> Expect.equal "02:04"
        , test "is 126:59 if the time is 7619023" <|
            \() ->
                Stopwatch.view 7619023
                    |> Expect.equal "126:59"
        ]
