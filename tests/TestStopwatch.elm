module TestStopwatch exposing (..)

import Stopwatch exposing (Stopwatch)
import Expect
import Test exposing (..)


stopwatch : Test
stopwatch =
    describe "Stopwatch"
        [ describe "basic operation"
            [ test "has an elapsed time of zero if not started" <|
                \() ->
                    Stopwatch.init
                        |> Stopwatch.tick 1000
                        |> Stopwatch.elapsed
                        |> Expect.equal 0
            , test "has an elapsed time of total ticks since started" <|
                \() ->
                    Stopwatch.init
                        |> Stopwatch.tick 1000
                        |> Stopwatch.start
                        |> Stopwatch.tick 53
                        |> Stopwatch.tick 10
                        |> Stopwatch.elapsed
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
                        |> Stopwatch.elapsed
                        |> Expect.equal 63
            , test "can be stopped" <|
                \() ->
                    Stopwatch.init
                        |> Stopwatch.tick 1000
                        |> Stopwatch.start
                        |> Stopwatch.tick 53
                        |> Stopwatch.stop
                        |> Stopwatch.tick 10
                        |> Stopwatch.elapsed
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
                        |> Stopwatch.elapsed
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
                        |> Stopwatch.elapsed
                        |> Expect.equal 10
            ]
        , describe "lap timer"
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
            ]
        ]
