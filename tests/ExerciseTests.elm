module ExerciseTests exposing (all)

import Char
import Exercise exposing (Exercise, Printable, Style(..))
import Expect
import Test exposing (..)


all : Test
all =
    describe "Exercise Tests"
        [ accuracyTests
        , consumeTests
        , eventStreamTests
        , isCompleteTests
        , isRunningTests
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
                        [ { content = "", style = Current } ]
        , test "return Printables for an exercise with nothing typed" <|
            \() ->
                exerciseWithText "a \n   \n b"
                    |> Exercise.printables
                    |> Expect.equal
                        [ { content = "a", style = Current }
                        , { content = "\u{000D}", style = Waiting }
                        , { content = "\n", style = Waiting }
                        , { content = "\u{000D}", style = Waiting }
                        , { content = " ", style = Waiting }
                        , { content = "b", style = Waiting }
                        , { content = "", style = Waiting }
                        ]
        , test "return Printables for an exercise with leading whitespace" <|
            \() ->
                exerciseWithText "  \n  a"
                    |> Exercise.printables
                    |> Expect.equal
                        [ { content = "\n ", style = Completed }
                        , { content = "\u{000D}", style = Completed }
                        , { content = "  ", style = Completed }
                        , { content = "a", style = Current }
                        , { content = "", style = Waiting }
                        ]

        -- , test "return Printables for an exercise with some stuff typed" <|
        --     \() ->
        --         exerciseWithText "a \n \n b"
        --             |> Exercise.consume 'a' 0
        --             |> Exercise.consume enterChar 0
        --             |> Exercise.printables
        --             |> Expect.equal
        --                 [ { content = "a", style = Completed }
        --                 , { content = "\n", style = Completed }
        --                 , { content = " ", style = Completed }
        --                 , { content = "\n", style = Completed }
        --                 , { content = " ", style = Completed }
        --                 , { content = "b", style = Current }
        --                 , { content = "", style = Waiting }
        --                 ]
        -- , test "return Printables with some stuff typed including an error" <|
        --     \() ->
        --         exerciseWithText "a \n bcd"
        --             |> Exercise.consume 'a' 0
        --             |> Exercise.consume enterChar 0
        --             |> Exercise.consume 'b' 0
        --             |> Exercise.consume 'b' 0
        --             |> Exercise.consume 'c' 0
        --             |> Exercise.consume backspaceChar 0
        --             |> Exercise.printables
        --             |> Expect.equal
        --                 [ { content = "a", style = Completed }
        --                 , { content = "\n", style = Completed }
        --                 , { content = " ", style = Completed }
        --                 , { content = "b", style = Completed }
        --                 , { content = "c", style = Error }
        --                 , { content = "d", style = Waiting }
        --                 , { content = "", style = Waiting }
        --                 ]
        -- , test "return Printables with some stuff typed including a" <|
        --     \() ->
        --         exerciseWithText "a \n bcd"
        --             |> Exercise.consume 'a' 0
        --             |> Exercise.consume enterChar 0
        --             |> Exercise.consume 'b' 0
        --             |> Exercise.consume 'b' 0
        --             |> Exercise.consume 'c' 0
        --             |> Exercise.consume backspaceChar 0
        --             |> Exercise.consume backspaceChar 0
        --             |> Exercise.consume 'c' 0
        --             |> Exercise.printables
        --             |> Expect.equal
        --                 [ { content = "a", style = Completed }
        --                 , { content = "\n", style = Completed }
        --                 , { content = " ", style = Completed }
        --                 , { content = "b", style = Completed }
        --                 , { content = "c", style = Completed }
        --                 , { content = "d", style = Current }
        --                 , { content = "", style = Waiting }
        --                 ]
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
                        [ { char = 'b', timeTaken = 2 }
                        , { char = 'a', timeTaken = 1 }
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
                        [ { char = backspaceChar, timeTaken = 0 }
                        , { char = 'c', timeTaken = 0 }
                        , { char = 'b', timeTaken = 0 }
                        , { char = backspaceChar, timeTaken = 0 }
                        , { char = 'a', timeTaken = 0 }
                        , { char = 'a', timeTaken = 0 }
                        ]
        , test "ignores leading whitespace and empty lines" <|
            \() ->
                exerciseWithText " a  \n  \n b"
                    |> Exercise.consume 'a' 0
                    |> Exercise.consume enterChar 0
                    |> Exercise.consume 'b' 0
                    |> .events
                    |> Expect.equal
                        [ { char = 'b', timeTaken = 0 }
                        , { char = enterChar, timeTaken = 0 }
                        , { char = 'a', timeTaken = 0 }
                        ]
        , test "stops when the exercise is complete" <|
            \() ->
                exerciseWithText "ab"
                    |> Exercise.consume 'a' 0
                    |> Exercise.consume 'b' 0
                    |> Exercise.consume 'c' 0
                    |> .events
                    |> Expect.equal
                        [ { char = 'b', timeTaken = 0 }
                        , { char = 'a', timeTaken = 0 }
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
                            [ { content = "a", style = Completed }
                            , { content = "b", style = Current }
                            , { content = "c", style = Waiting }
                            , { content = "", style = Waiting }
                            ]
            , test "handles newlines in the string" <|
                \() ->
                    exerciseWithText "ab\nc"
                        |> Exercise.consume 'a' 0
                        |> Exercise.consume 'b' 0
                        |> Exercise.consume enterChar 0
                        |> Exercise.printables
                        |> Expect.equal
                            [ { content = "a", style = Completed }
                            , { content = "b", style = Completed }
                            , { content = "\u{000D}", style = Completed }
                            , { content = "c", style = Current }
                            , { content = "", style = Waiting }
                            ]
            , test "won't advance if the wrong character is given" <|
                \() ->
                    exerciseWithText "abc"
                        |> Exercise.consume 'a' 0
                        |> Exercise.consume 'c' 0
                        |> Exercise.printables
                        |> Expect.equal
                            [ { content = "a", style = Completed }
                            , { content = "b", style = Error }
                            , { content = "c", style = Waiting }
                            , { content = "", style = Waiting }
                            ]
            , test "handles leading whitespace" <|
                \() ->
                    exerciseWithText "ab\n  cd"
                        |> Exercise.consume 'a' 0
                        |> Exercise.consume 'b' 0
                        |> Exercise.consume enterChar 0
                        |> Exercise.printables
                        |> Expect.equal
                            [ { content = "a", style = Completed }
                            , { content = "b", style = Completed }
                            , { content = "\u{000D}", style = Completed }
                            , { content = "  ", style = Completed }
                            , { content = "c", style = Current }
                            , { content = "d", style = Waiting }
                            , { content = "", style = Waiting }
                            ]
            ]
        , describe "consume with backspace"
            [ test "does nothing if at the start of a new string" <|
                \() ->
                    exerciseWithText "abc"
                        |> Exercise.consume backspaceChar 0
                        |> Exercise.printables
                        |> Expect.equal
                            [ { content = "a", style = Current }
                            , { content = "b", style = Waiting }
                            , { content = "c", style = Waiting }
                            , { content = "", style = Waiting }
                            ]
            , test "goes back a character if beyond the start" <|
                \() ->
                    exerciseWithText "abc"
                        |> Exercise.consume 'a' 0
                        |> Exercise.consume 'b' 0
                        |> Exercise.consume backspaceChar 0
                        |> Exercise.printables
                        |> Expect.equal
                            [ { content = "a", style = Completed }
                            , { content = "b", style = Current }
                            , { content = "c", style = Waiting }
                            , { content = "", style = Waiting }
                            ]
            , test "resets a single error" <|
                \() ->
                    exerciseWithText "abc"
                        |> Exercise.consume 'a' 0
                        |> Exercise.consume 'c' 0
                        |> Exercise.consume backspaceChar 0
                        |> Exercise.printables
                        |> Expect.equal
                            [ { content = "a", style = Completed }
                            , { content = "b", style = Current }
                            , { content = "c", style = Waiting }
                            , { content = "", style = Waiting }
                            ]
            ]
        ]


isRunningTests : Test
isRunningTests =
    describe "isRunning"
        [ test "returns False for a new exercise" <|
            \() ->
                exerciseWithText "a"
                    |> Exercise.isRunning
                    |> Expect.equal False
        , test "returns True for an exercise with a correct character entered" <|
            \() ->
                exerciseWithText "ab"
                    |> Exercise.consume 'a' 0
                    |> Exercise.isRunning
                    |> Expect.equal True
        , test "returns True for an exercise with an incorrect character entered" <|
            \() ->
                exerciseWithText "ab"
                    |> Exercise.consume 'b' 0
                    |> Exercise.isRunning
                    |> Expect.equal True
        , test "returns False for a completed exercise" <|
            \() ->
                exerciseWithText "ab"
                    |> Exercise.consume 'a' 0
                    |> Exercise.consume 'b' 0
                    |> Exercise.isRunning
                    |> Expect.equal False
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


backspaceChar : Char
backspaceChar =
    Char.fromCode 8


enterChar : Char
enterChar =
    Char.fromCode 13


exerciseWithText : String -> Exercise
exerciseWithText text =
    Exercise.init 0 "" text
