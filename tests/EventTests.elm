module EventTests exposing (all)

import Char
import Event exposing (Event)
import Expect
import Test exposing (..)


all : Test
all =
    describe "Event Tests"
        [ timeTakenTests
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


eventsWithCorrectedMistake : List Event
eventsWithCorrectedMistake =
    [ Event 'a' 10000
    , Event 'b' 10000
    , Event 'c' 10000
    , Event ' ' 10000
    , Event 'd' 10000
    , Event 'd' 10000
    , Event backspaceChar 10000
    , Event 'e' 10000
    , Event 'f' 10000
    , Event ' ' 10000
    , Event 'g' 10000
    , Event 'h' 10000
    ]


backspaceChar : Char
backspaceChar =
    Char.fromCode 8
