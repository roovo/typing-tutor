module TestExercise exposing (..)

import Char
import Exercise exposing (Exercise)
import Expect
import Step exposing (Step, Direction(..), Status(..))
import Test exposing (..)


backspaceChar =
    (Char.fromCode 8)


exercise : Test
exercise =
    describe "Exercise"
        [ describe "steps"
            [ test "returns a list with only the end item for an empty string" <|
                \() ->
                    Exercise.init ""
                        |> Exercise.steps
                        |> Expect.equal [ { content = "", status = End, moveTo = None } ]
            , test "returns multiple chunks for a multi-character string" <|
                \() ->
                    Exercise.init "abc"
                        |> Exercise.steps
                        |> Expect.equal
                            [ { content = "a", status = Current, moveTo = None }
                            , { content = "b", status = Waiting, moveTo = None }
                            , { content = "c", status = Waiting, moveTo = None }
                            , { content = "", status = End, moveTo = None }
                            ]
            ]
        , describe "consume"
            [ test "advances to the next character in the string" <|
                \() ->
                    Exercise.init "abc"
                        |> Exercise.consume 'a'
                        |> Exercise.steps
                        |> Expect.equal
                            [ { content = "a", status = Completed, moveTo = Next }
                            , { content = "b", status = Current, moveTo = None }
                            , { content = "c", status = Waiting, moveTo = None }
                            , { content = "", status = End, moveTo = None }
                            ]
            , test "won't advance if the wrong character is given" <|
                \() ->
                    Exercise.init "abc"
                        |> Exercise.consume 'a'
                        |> Exercise.consume 'c'
                        |> Exercise.steps
                        |> Expect.equal
                            [ { content = "a", status = Completed, moveTo = Next }
                            , { content = "b", status = Error 1, moveTo = None }
                            , { content = "c", status = Waiting, moveTo = None }
                            , { content = "", status = End, moveTo = None }
                            ]
            ]
        , describe "consume with backspace"
            [ test "does nothing if at the start of a new string" <|
                \() ->
                    Exercise.init "abc"
                        |> Exercise.consume backspaceChar
                        |> Exercise.steps
                        |> Expect.equal
                            [ { content = "a", status = Current, moveTo = Previous }
                            , { content = "b", status = Waiting, moveTo = None }
                            , { content = "c", status = Waiting, moveTo = None }
                            , { content = "", status = End, moveTo = None }
                            ]
            , test "goes back a character if beyond the start" <|
                \() ->
                    Exercise.init "abc"
                        |> Exercise.consume 'a'
                        |> Exercise.consume 'b'
                        |> Exercise.consume backspaceChar
                        |> Exercise.steps
                        |> Expect.equal
                            [ { content = "a", status = Completed, moveTo = Next }
                            , { content = "b", status = Current, moveTo = Next }
                            , { content = "c", status = Waiting, moveTo = Previous }
                            , { content = "", status = End, moveTo = None }
                            ]
            , test "resets a single error" <|
                \() ->
                    Exercise.init "abc"
                        |> Exercise.consume 'a'
                        |> Exercise.consume 'c'
                        |> Exercise.consume backspaceChar
                        |> Exercise.steps
                        |> Expect.equal
                            [ { content = "a", status = Completed, moveTo = Next }
                            , { content = "b", status = Current, moveTo = None }
                            , { content = "c", status = Waiting, moveTo = None }
                            , { content = "", status = End, moveTo = None }
                            ]
            ]
        , describe "isComplete"
            [ test "returns False for a new script" <|
                \() ->
                    Exercise.init "a"
                        |> Exercise.isComplete
                        |> Expect.equal False
            , test "returns False with an error" <|
                \() ->
                    Exercise.init "a"
                        |> Exercise.consume 'b'
                        |> Exercise.isComplete
                        |> Expect.equal False
            , test "returns True if at the end" <|
                \() ->
                    Exercise.init "ab"
                        |> Exercise.consume 'a'
                        |> Exercise.consume 'b'
                        |> Exercise.isComplete
                        |> Expect.equal True
            ]
        ]
