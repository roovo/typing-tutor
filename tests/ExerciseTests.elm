module ExerciseTests exposing (all)

import Char
import Exercise exposing (Exercise)
import Expect
import Step exposing (Step, Direction(..), Status(..))
import Test exposing (..)


all : Test
all =
    describe "Exercise Tests"
        [ stepsTests
        , consumeTests
        , isCompleteTests
        , timeTakenTests
        , wpmTests
        , accuracyTests
        ]


stepsTests : Test
stepsTests =
    describe "init / steps"
        [ test "returns a list with only the end item for an empty string" <|
            \() ->
                exerciseWithText ""
                    |> Exercise.steps
                    |> Expect.equal [ { content = "", status = End, moveTo = None } ]
        , test "returns multiple chunks for a multi-character string" <|
            \() ->
                exerciseWithText "abc"
                    |> Exercise.steps
                    |> Expect.equal
                        [ { content = "a", status = Current, moveTo = None }
                        , { content = "b", status = Waiting, moveTo = None }
                        , { content = "c", status = Waiting, moveTo = None }
                        , { content = "", status = End, moveTo = None }
                        ]
        , test "skips whitespace at the start of the first line" <|
            \() ->
                exerciseWithText "  abc"
                    |> Exercise.steps
                    |> Expect.equal
                        [ { content = "  ", status = Skip, moveTo = None }
                        , { content = "a", status = Current, moveTo = None }
                        , { content = "b", status = Waiting, moveTo = None }
                        , { content = "c", status = Waiting, moveTo = None }
                        , { content = "", status = End, moveTo = None }
                        ]
        , test "skips whitespace-only lines at the start" <|
            \() ->
                exerciseWithText "  \n  abc"
                    |> Exercise.steps
                    |> Expect.equal
                        [ { content = "  ", status = Skip, moveTo = None }
                        , { content = "\x0D", status = Skip, moveTo = None }
                        , { content = "  ", status = Skip, moveTo = None }
                        , { content = "a", status = Current, moveTo = None }
                        , { content = "b", status = Waiting, moveTo = None }
                        , { content = "c", status = Waiting, moveTo = None }
                        , { content = "", status = End, moveTo = None }
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
                        |> Exercise.steps
                        |> Expect.equal
                            [ { content = "a", status = Completed, moveTo = Next }
                            , { content = "b", status = Current, moveTo = None }
                            , { content = "c", status = Waiting, moveTo = None }
                            , { content = "", status = End, moveTo = None }
                            ]
            , test "handles newlines in the string" <|
                \() ->
                    exerciseWithText "ab\nc"
                        |> Exercise.consume 'a' 0
                        |> Exercise.consume 'b' 0
                        |> Exercise.consume enterChar 0
                        |> Exercise.steps
                        |> Expect.equal
                            [ { content = "a", status = Completed, moveTo = Next }
                            , { content = "b", status = Completed, moveTo = Next }
                            , { content = "\x0D", status = Completed, moveTo = Next }
                            , { content = "c", status = Current, moveTo = None }
                            , { content = "", status = End, moveTo = None }
                            ]
            , test "won't advance if the wrong character is given" <|
                \() ->
                    exerciseWithText "abc"
                        |> Exercise.consume 'a' 0
                        |> Exercise.consume 'c' 0
                        |> Exercise.steps
                        |> Expect.equal
                            [ { content = "a", status = Completed, moveTo = Next }
                            , { content = "b", status = Error 1, moveTo = None }
                            , { content = "c", status = Waiting, moveTo = None }
                            , { content = "", status = End, moveTo = None }
                            ]
            , test "handles leading whitespace" <|
                \() ->
                    exerciseWithText "ab\n  cd"
                        |> Exercise.consume 'a' 0
                        |> Exercise.consume 'b' 0
                        |> Exercise.consume enterChar 0
                        |> Exercise.steps
                        |> Expect.equal
                            [ { content = "a", status = Completed, moveTo = Next }
                            , { content = "b", status = Completed, moveTo = Next }
                            , { content = "\x0D", status = Completed, moveTo = Next }
                            , { content = "  ", status = Skip, moveTo = None }
                            , { content = "c", status = Current, moveTo = None }
                            , { content = "d", status = Waiting, moveTo = None }
                            , { content = "", status = End, moveTo = None }
                            ]
            ]
        , describe "consume with backspace"
            [ test "does nothing if at the start of a new string" <|
                \() ->
                    exerciseWithText "abc"
                        |> Exercise.consume backspaceChar 0
                        |> Exercise.steps
                        |> Expect.equal
                            [ { content = "a", status = Current, moveTo = Previous }
                            , { content = "b", status = Waiting, moveTo = None }
                            , { content = "c", status = Waiting, moveTo = None }
                            , { content = "", status = End, moveTo = None }
                            ]
            , test "goes back a character if beyond the start" <|
                \() ->
                    exerciseWithText "abc"
                        |> Exercise.consume 'a' 0
                        |> Exercise.consume 'b' 0
                        |> Exercise.consume backspaceChar 0
                        |> Exercise.steps
                        |> Expect.equal
                            [ { content = "a", status = Completed, moveTo = Next }
                            , { content = "b", status = Current, moveTo = Next }
                            , { content = "c", status = Waiting, moveTo = Previous }
                            , { content = "", status = End, moveTo = None }
                            ]
            , test "resets a single error" <|
                \() ->
                    exerciseWithText "abc"
                        |> Exercise.consume 'a' 0
                        |> Exercise.consume 'c' 0
                        |> Exercise.consume backspaceChar 0
                        |> Exercise.steps
                        |> Expect.equal
                            [ { content = "a", status = Completed, moveTo = Next }
                            , { content = "b", status = Current, moveTo = None }
                            , { content = "c", status = Waiting, moveTo = None }
                            , { content = "", status = End, moveTo = None }
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


timeTakenTests : Test
timeTakenTests =
    describe "timeTaken"
        [ test "returns 0 with nothing typed" <|
            \() ->
                exerciseWithText "a"
                    |> Exercise.timeTaken
                    |> Expect.equal 0
        , test "returns the sum of the times taken for each consumed character" <|
            \() ->
                exerciseWithText "abc"
                    |> Exercise.consume 'a' 10
                    |> Exercise.consume 'c' 22
                    |> Exercise.consume backspaceChar 3
                    |> Exercise.consume 'b' 15
                    |> Exercise.timeTaken
                    |> Expect.equal 50
        , test "stops summing when the exercise is complete" <|
            \() ->
                exerciseWithText "ab"
                    |> Exercise.consume 'a' 10
                    |> Exercise.consume 'b' 22
                    |> Exercise.consume 'b' 15
                    |> Exercise.timeTaken
                    |> Expect.equal 32
        ]


wpmTests : Test
wpmTests =
    describe "wpm"
        [ test "returns 0 with nothing typed" <|
            \() ->
                exerciseWithText "a"
                    |> Exercise.wpm
                    |> Expect.equal 0
        , test "a word is defined as 5 characters (incl spaces) in the target string" <|
            \() ->
                exerciseWithText "abc def gh"
                    |> Exercise.consume 'a' 10000
                    |> Exercise.consume 'b' 10000
                    |> Exercise.consume 'c' 10000
                    |> Exercise.consume ' ' 10000
                    |> Exercise.consume 'd' 10000
                    |> Exercise.consume 'd' 10000
                    |> Exercise.consume backspaceChar 10000
                    |> Exercise.consume 'e' 10000
                    |> Exercise.consume 'f' 10000
                    |> Exercise.consume ' ' 10000
                    |> Exercise.consume 'g' 10000
                    |> Exercise.consume 'h' 10000
                    |> Exercise.wpm
                    |> Expect.equal 1
        ]


accuracyTests : Test
accuracyTests =
    describe "accuracy"
        [ test "returns 0% for a single character with nothing typed" <|
            \() ->
                exerciseWithText "a"
                    |> Exercise.accuracy
                    |> Expect.equal 0
        , test "returns 100% for a single character with only a single bad character typed" <|
            \() ->
                exerciseWithText "a"
                    |> Exercise.consume 'b' 0
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
        , test "returns 100% for a single character typed correctly" <|
            \() ->
                exerciseWithText "a"
                    |> Exercise.consume 'a' 0
                    |> Exercise.accuracy
                    |> Expect.equal 100
        , test "returns 100% for a multiple characters typed correctly" <|
            \() ->
                exerciseWithText "abc"
                    |> Exercise.consume 'a' 0
                    |> Exercise.consume 'b' 0
                    |> Exercise.consume 'c' 0
                    |> Exercise.accuracy
                    |> Expect.equal 100
        , test "returns 100% for a multiple characters typed correctly with a line containing whitespace" <|
            \() ->
                exerciseWithText "a\n b"
                    |> Exercise.consume 'a' 0
                    |> Exercise.consume enterChar 0
                    |> Exercise.consume 'b' 0
                    |> Exercise.accuracy
                    |> Expect.equal 100
        , test "returns 66.66% for a 2 corrected mistakes in a total of 4" <|
            \() ->
                exerciseWithText "abcd"
                    |> Exercise.consume 'a' 0
                    |> Exercise.consume 'c' 0
                    |> Exercise.consume backspaceChar 0
                    |> Exercise.consume 'b' 0
                    |> Exercise.consume 'c' 0
                    |> Exercise.consume 'c' 0
                    |> Exercise.consume backspaceChar 0
                    |> Exercise.consume 'd' 0
                    |> Exercise.accuracy
                    |> (*) 100
                    |> truncate
                    |> toFloat
                    |> (flip (/) 100.0)
                    |> Expect.equal 66.66
        ]


backspaceChar =
    (Char.fromCode 8)


enterChar =
    (Char.fromCode 13)


exerciseWithText : String -> Exercise
exerciseWithText text =
    Exercise.init 0 "" text
