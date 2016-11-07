module EventTests exposing (all)

import Event exposing (Event)
import Expect
import Step exposing (Step, Direction(..), Status(..))
import Test exposing (..)


all : Test
all =
    describe "Event Tests"
        [ timeTakenTests
        , wpmTests
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
