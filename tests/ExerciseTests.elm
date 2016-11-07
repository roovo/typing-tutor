module ExerciseTests exposing (all)

import Char
import Exercise exposing (Exercise, Printable, Style(..))
import Expect
import Step exposing (Step, Direction(..))
import Test exposing (..)


all : Test
all =
    describe "Exercise Tests"
        [ accuracyTests
        , consumeTests
        , eventStreamTests
        , isCompleteTests
        , printablesTests
        , wpmTests
        ]


accuracyTests : Test
accuracyTests =
    describe "accuracy"
        [ test "returns 0% for empty exercise with nothing typed" <|
            \() ->
                exerciseWithText ""
                    |> Exercise.accuracy
                    |> Expect.equal 0
        , test "returns 0% for a single character incorrectly typed" <|
            \() ->
                exerciseWithText "a"
                    |> Exercise.consume 'b' 0
                    |> Exercise.accuracy
                    |> Expect.equal 0
        , test "returns 100% for a single character correctly typed" <|
            \() ->
                exerciseWithText "a"
                    |> Exercise.consume 'a' 0
                    |> Exercise.accuracy
                    |> Expect.equal 100
        , test "returns 50% for a single character with a corrected single bad character typed" <|
            \() ->
                exerciseWithText "a"
                    |> Exercise.consume 'b' 0
                    |> Exercise.consume backspaceChar 0
                    |> Exercise.consume 'a' 0
                    |> Exercise.accuracy
                    |> Expect.equal 50
        , test "returns 100% for a multiple characters correctly typed" <|
            \() ->
                exerciseWithText "abc"
                    |> Exercise.consume 'a' 0
                    |> Exercise.consume 'b' 0
                    |> Exercise.consume 'c' 0
                    |> Exercise.accuracy
                    |> Expect.equal 100
        , test "counts the return key as a character" <|
            \() ->
                exerciseWithText "a\nbc"
                    |> Exercise.consume 'a' 0
                    |> Exercise.consume enterChar 0
                    |> Exercise.consume 'b' 0
                    |> Exercise.consume 'b' 0
                    |> Exercise.accuracy
                    |> Expect.equal 75
        , test "doesn't count correctly typed characters when in error state" <|
            \() ->
                exerciseWithText "abc"
                    |> Exercise.consume 'a' 0
                    |> Exercise.consume 'a' 0
                    |> Exercise.consume 'b' 0
                    |> Exercise.consume backspaceChar 0
                    |> Exercise.consume backspaceChar 0
                    |> Exercise.consume 'b' 0
                    |> Exercise.accuracy
                    |> Expect.equal 50
        ]


printablesTests : Test
printablesTests =
    describe "printables tests"
        [ test "returns a list with just the end for an empty Exercise" <|
            \() ->
                exerciseWithText ""
                    |> Exercise.printables
                    |> Expect.equal
                        [ { content = "", style = SCurrent } ]
        , test "return Printables for an exercise with nothing typed" <|
            \() ->
                exerciseWithText "a \n \n b"
                    |> Exercise.printables
                    |> Expect.equal
                        [ { content = "a", style = SCurrent }
                        , { content = "\x0D", style = SWaiting }
                        , { content = " ", style = SWaiting }
                        , { content = "\x0D", style = SWaiting }
                        , { content = " ", style = SWaiting }
                        , { content = "b", style = SWaiting }
                        , { content = "", style = SWaiting }
                        ]
        , test "return Printables for an exercise with leading whitespace" <|
            \() ->
                exerciseWithText "  \n  a"
                    |> Exercise.printables
                    |> Expect.equal
                        [ { content = "  ", style = SCompleted }
                        , { content = "\x0D", style = SCompleted }
                        , { content = "  ", style = SCompleted }
                        , { content = "a", style = SCurrent }
                        , { content = "", style = SWaiting }
                        ]
        , test "return Printables for an exercise with some stuff typed" <|
            \() ->
                exerciseWithText "a \n \n b"
                    |> Exercise.consume 'a' 0
                    |> Exercise.consume enterChar 0
                    |> Exercise.printables
                    |> Expect.equal
                        [ { content = "a", style = SCompleted }
                        , { content = "\x0D", style = SCompleted }
                        , { content = " ", style = SCompleted }
                        , { content = "\x0D", style = SCompleted }
                        , { content = " ", style = SCompleted }
                        , { content = "b", style = SCurrent }
                        , { content = "", style = SWaiting }
                        ]
        , test "return Printables with some stuff typed including an error" <|
            \() ->
                exerciseWithText "a \n bcd"
                    |> Exercise.consume 'a' 0
                    |> Exercise.consume enterChar 0
                    |> Exercise.consume 'b' 0
                    |> Exercise.consume 'b' 0
                    |> Exercise.consume 'c' 0
                    |> Exercise.consume backspaceChar 0
                    |> Exercise.printables
                    |> Expect.equal
                        [ { content = "a", style = SCompleted }
                        , { content = "\x0D", style = SCompleted }
                        , { content = " ", style = SCompleted }
                        , { content = "b", style = SCompleted }
                        , { content = "c", style = SError }
                        , { content = "d", style = SWaiting }
                        , { content = "", style = SWaiting }
                        ]
        , test "return Printables with some stuff typed including a" <|
            \() ->
                exerciseWithText "a \n bcd"
                    |> Exercise.consume 'a' 0
                    |> Exercise.consume enterChar 0
                    |> Exercise.consume 'b' 0
                    |> Exercise.consume 'b' 0
                    |> Exercise.consume 'c' 0
                    |> Exercise.consume backspaceChar 0
                    |> Exercise.consume backspaceChar 0
                    |> Exercise.consume 'c' 0
                    |> Exercise.printables
                    |> Expect.equal
                        [ { content = "a", style = SCompleted }
                        , { content = "\x0D", style = SCompleted }
                        , { content = " ", style = SCompleted }
                        , { content = "b", style = SCompleted }
                        , { content = "c", style = SCompleted }
                        , { content = "d", style = SCurrent }
                        , { content = "", style = SWaiting }
                        ]
        ]


eventStreamTests : Test
eventStreamTests =
    describe "event stream tests"
        [ test "returns an empty stream if nothing has been typed" <|
            \() ->
                exerciseWithText "ab"
                    |> .events
                    |> Expect.equal []
        , test "returns stream of correctly type characters" <|
            \() ->
                exerciseWithText "ab"
                    |> Exercise.consume 'a' 1
                    |> Exercise.consume 'b' 2
                    |> .events
                    |> Expect.equal
                        [ { expected = "b", actual = "b", timeTaken = 2 }
                        , { expected = "a", actual = "a", timeTaken = 1 }
                        ]
        , test "includes mistakes, backspaces and corrections" <|
            \() ->
                exerciseWithText "abcd"
                    |> Exercise.consume 'a' 0
                    |> Exercise.consume 'a' 0
                    |> Exercise.consume backspaceChar 0
                    |> Exercise.consume 'b' 0
                    |> Exercise.consume 'c' 0
                    |> Exercise.consume backspaceChar 0
                    |> .events
                    |> Expect.equal
                        [ { expected = "d", actual = "\x08", timeTaken = 0 }
                        , { expected = "c", actual = "c", timeTaken = 0 }
                        , { expected = "b", actual = "b", timeTaken = 0 }
                        , { expected = "b", actual = "\x08", timeTaken = 0 }
                        , { expected = "b", actual = "a", timeTaken = 0 }
                        , { expected = "a", actual = "a", timeTaken = 0 }
                        ]
        , test "ignores leading whitespace and empty lines" <|
            \() ->
                exerciseWithText " a  \n  \n b"
                    |> Exercise.consume 'a' 0
                    |> Exercise.consume enterChar 0
                    |> Exercise.consume 'b' 0
                    |> .events
                    |> Expect.equal
                        [ { expected = "b", actual = "b", timeTaken = 0 }
                        , { expected = "\x0D", actual = "\x0D", timeTaken = 0 }
                        , { expected = "a", actual = "a", timeTaken = 0 }
                        ]
        , test "stops when the exercise is complete" <|
            \() ->
                exerciseWithText "ab"
                    |> Exercise.consume 'a' 0
                    |> Exercise.consume 'b' 0
                    |> Exercise.consume 'c' 0
                    |> .events
                    |> Expect.equal
                        [ { expected = "b", actual = "b", timeTaken = 0 }
                        , { expected = "a", actual = "a", timeTaken = 0 }
                        ]
        ]


consumeTests : Test
consumeTests =
    describe "consume"
        [ describe "consume with no backspaces"
            [ test "advances to the next character in the string" <|
                \() ->
                    exerciseWithText "abc"
                        |> Exercise.consume 'a' 0
                        |> Exercise.printables
                        |> Expect.equal
                            [ { content = "a", style = SCompleted }
                            , { content = "b", style = SCurrent }
                            , { content = "c", style = SWaiting }
                            , { content = "", style = SWaiting }
                            ]
            , test "handles newlines in the string" <|
                \() ->
                    exerciseWithText "ab\nc"
                        |> Exercise.consume 'a' 0
                        |> Exercise.consume 'b' 0
                        |> Exercise.consume enterChar 0
                        |> Exercise.printables
                        |> Expect.equal
                            [ { content = "a", style = SCompleted }
                            , { content = "b", style = SCompleted }
                            , { content = "\x0D", style = SCompleted }
                            , { content = "c", style = SCurrent }
                            , { content = "", style = SWaiting }
                            ]
            , test "won't advance if the wrong character is given" <|
                \() ->
                    exerciseWithText "abc"
                        |> Exercise.consume 'a' 0
                        |> Exercise.consume 'c' 0
                        |> Exercise.printables
                        |> Expect.equal
                            [ { content = "a", style = SCompleted }
                            , { content = "b", style = SError }
                            , { content = "c", style = SWaiting }
                            , { content = "", style = SWaiting }
                            ]
            , test "handles leading whitespace" <|
                \() ->
                    exerciseWithText "ab\n  cd"
                        |> Exercise.consume 'a' 0
                        |> Exercise.consume 'b' 0
                        |> Exercise.consume enterChar 0
                        |> Exercise.printables
                        |> Expect.equal
                            [ { content = "a", style = SCompleted }
                            , { content = "b", style = SCompleted }
                            , { content = "\x0D", style = SCompleted }
                            , { content = "  ", style = SCompleted }
                            , { content = "c", style = SCurrent }
                            , { content = "d", style = SWaiting }
                            , { content = "", style = SWaiting }
                            ]
            ]
        , describe "consume with backspace"
            [ test "does nothing if at the start of a new string" <|
                \() ->
                    exerciseWithText "abc"
                        |> Exercise.consume backspaceChar 0
                        |> Exercise.printables
                        |> Expect.equal
                            [ { content = "a", style = SCurrent }
                            , { content = "b", style = SWaiting }
                            , { content = "c", style = SWaiting }
                            , { content = "", style = SWaiting }
                            ]
            , test "goes back a character if beyond the start" <|
                \() ->
                    exerciseWithText "abc"
                        |> Exercise.consume 'a' 0
                        |> Exercise.consume 'b' 0
                        |> Exercise.consume backspaceChar 0
                        |> Exercise.printables
                        |> Expect.equal
                            [ { content = "a", style = SCompleted }
                            , { content = "b", style = SCurrent }
                            , { content = "c", style = SWaiting }
                            , { content = "", style = SWaiting }
                            ]
            , test "resets a single error" <|
                \() ->
                    exerciseWithText "abc"
                        |> Exercise.consume 'a' 0
                        |> Exercise.consume 'c' 0
                        |> Exercise.consume backspaceChar 0
                        |> Exercise.printables
                        |> Expect.equal
                            [ { content = "a", style = SCompleted }
                            , { content = "b", style = SCurrent }
                            , { content = "c", style = SWaiting }
                            , { content = "", style = SWaiting }
                            ]
            ]
        ]


isCompleteTests : Test
isCompleteTests =
    describe "isComplete"
        [ test "returns False for a new script" <|
            \() ->
                exerciseWithText "a"
                    |> Exercise.isComplete
                    |> Expect.equal False
        , test "returns False with an error" <|
            \() ->
                exerciseWithText "a"
                    |> Exercise.consume 'b' 0
                    |> Exercise.isComplete
                    |> Expect.equal False
        , test "returns True if at the end" <|
            \() ->
                exerciseWithText "ab"
                    |> Exercise.consume 'a' 0
                    |> Exercise.consume 'b' 0
                    |> Exercise.isComplete
                    |> Expect.equal True
        ]


wpmTests : Test
wpmTests =
    describe "wpm"
        [ test "returns 0 for empty exercise with nothing typed" <|
            \() ->
                exerciseWithText ""
                    |> Exercise.wpm
                    |> Expect.equal 0
          -- , test "a word is defined as 5 characters (incl spaces) in the target string" <|
          --     \() ->
          --         eventsWithCorrectedMistake
          --             |> Event.wpm
          --             |> Expect.equal 1
        ]


backspaceChar =
    (Char.fromCode 8)


enterChar =
    (Char.fromCode 13)


exerciseWithText : String -> Exercise
exerciseWithText text =
    Exercise.init 0 "" text
