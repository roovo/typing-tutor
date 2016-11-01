module EventTests exposing (all)

import Event exposing (Event)
import Expect
import Step exposing (Step, Direction(..), Status(..))
import Test exposing (..)


all : Test
all =
    describe "Event Tests"
        [ accuracyTests
        , timeTakenTests
        , wpmTests
        ]


accuracyTests : Test
accuracyTests =
    describe "accuracy"
        [ test "returns 0% for no Events" <|
            \() ->
                []
                    |> Event.accuracy
                    |> Expect.equal 0
        , test "returns 0% for a single Event with a bad character typed" <|
            \() ->
                [ Event "a" "b" 0 ]
                    |> Event.accuracy
                    |> Expect.equal 0
        , test "returns 100% for a single character typed correctly" <|
            \() ->
                [ Event "a" "a" 0 ]
                    |> Event.accuracy
                    |> Expect.equal 100
        , test "returns 50% for a single character with a corrected single bad character typed" <|
            \() ->
                [ Event "a" "b" 0
                , Event "a" "\x08" 0
                , Event "a" "a" 0
                ]
                    |> Event.accuracy
                    |> Expect.equal 50
        , test "returns 100% for a multiple characters typed correctly" <|
            \() ->
                [ Event "a" "a" 0
                , Event "b" "b" 0
                , Event "c" "c" 0
                ]
                    |> Event.accuracy
                    |> Expect.equal 100
        , test "counts the return key as a character" <|
            \() ->
                [ Event "a" "a" 0
                , Event "\x0D" "\x0D" 0
                , Event "b" "b" 0
                ]
                    |> Event.accuracy
                    |> Expect.equal 100
        , test "doesn't count correctly typed characters when in error state" <|
            \() ->
                [ Event "a" "a" 0
                , Event "b" "a" 0
                , Event "b" "b" 0
                , Event "b" "\x08" 0
                , Event "b" "\x08" 0
                , Event "b" "b" 0
                ]
                    |> Event.accuracy
                    |> Expect.equal 50
        , test "returns 66.66% for a 2 corrected mistakes in a total of 4" <|
            \() ->
                [ Event "a" "a" 0
                , Event "b" "c" 0
                , Event "b" "\x08" 0
                , Event "b" "b" 0
                , Event "c" "c" 0
                , Event "d" "c" 0
                , Event "d" "\x08" 0
                , Event "d" "d" 0
                ]
                    |> Event.accuracy
                    |> (*) 100
                    |> truncate
                    |> toFloat
                    |> (flip (/) 100.0)
                    |> Expect.equal 66.66
        ]


timeTakenTests : Test
timeTakenTests =
    describe "timeTaken"
        [ test "returns 0 with no Events" <|
            \() ->
                []
                    |> Event.timeTaken
                    |> Expect.equal 0
        , test "returns the sum of the times taken for all consumed characters (including backspaces" <|
            \() ->
                eventsWithCorrectedMistake
                    |> Event.timeTaken
                    |> Expect.equal 120000
        ]


wpmTests : Test
wpmTests =
    describe "wpm"
        [ test "returns 0 with no Events" <|
            \() ->
                []
                    |> Event.wpm
                    |> Expect.equal 0
        , test "a word is defined as 5 characters (incl spaces) in the target string" <|
            \() ->
                eventsWithCorrectedMistake
                    |> Event.wpm
                    |> Expect.equal 1
        ]


eventsWithCorrectedMistake =
    [ Event "a" "a" 10000
    , Event "b" "b" 10000
    , Event "c" "c" 10000
    , Event " " " " 10000
    , Event "d" "d" 10000
    , Event "e" "d" 10000
    , Event "e" "\x08" 10000
    , Event "e" "e" 10000
    , Event "f" "f" 10000
    , Event " " " " 10000
    , Event "g" "g" 10000
    , Event "h" "h" 10000
    ]
