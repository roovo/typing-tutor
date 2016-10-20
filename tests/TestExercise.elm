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
        -- [ describe "steps"
        --     [ test "returns a list with only the end item for an empty string" <|
        --         \() ->
        --             Exercise.init ""
        --                 |> Exercise.steps
        --                 |> Expect.equal [ { content = "", status = End, moveTo = None } ]
        --     , test "returns multiple chunks for a multi-character string" <|
        --         \() ->
        --             Exercise.init "abc"
        --                 |> Exercise.steps
        --                 |> Expect.equal
        --                     [ { content = "a", status = Current, moveTo = None }
        --                     , { content = "b", status = Waiting, moveTo = None }
        --                     , { content = "c", status = Waiting, moveTo = None }
        --                     , { content = "", status = End, moveTo = None }
        --                     ]
        --     ]
        -- , describe "consume"
        --     [ test "advances to the next character in the string" <|
        --         \() ->
        --             Exercise.init "abc"
        --                 |> Exercise.consume 'a'
        --                 |> Exercise.steps
        --                 |> Expect.equal
        --                     [ { content = "a", status = Completed, moveTo = Next }
        --                     , { content = "b", status = Current, moveTo = None }
        --                     , { content = "c", status = Waiting, moveTo = None }
        --                     , { content = "", status = End, moveTo = None }
        --                     ]
        --     , test "won't advance if the wrong character is given" <|
        --         \() ->
        --             Exercise.init "abc"
        --                 |> Exercise.consume 'a'
        --                 |> Exercise.consume 'c'
        --                 |> Exercise.steps
        --                 |> Expect.equal
        --                     [ { content = "a", status = Completed, moveTo = Next }
        --                     , { content = "b", status = Current, moveTo = NewBranch }
        --                     , { content = "c", status = Waiting, moveTo = None }
        --                     , { content = "", status = End, moveTo = None }
        --                     ]
        --     ]
        [ describe "consume with backspace"
            -- [ test "does nothing if at the start of a new string" <|
            --     \() ->
            --         Exercise.init "abc"
            --             |> Exercise.consume backspaceChar
            --             |> Exercise.steps
            --             |> Expect.equal
            --                 [ { content = "a", status = Current, moveTo = Previous }
            --                 , { content = "b", status = Waiting, moveTo = None }
            --                 , { content = "c", status = Waiting, moveTo = None }
            --                 , { content = "", status = End, moveTo = None }
            --                 ]
            -- , test "goes back a character if beyond the start" <|
            --     \() ->
            --         Exercise.init "abc"
            --             |> Exercise.consume 'a'
            --             |> Exercise.consume 'b'
            --             |> Exercise.consume backspaceChar
            --             |> Exercise.steps
            --             |> Expect.equal
            --                 [ { content = "a", status = Completed, moveTo = Next }
            --                 , { content = "b", status = Current, moveTo = Next }
            --                 , { content = "c", status = Waiting, moveTo = Previous }
            --                 , { content = "", status = End, moveTo = None }
            --                 ]
            [ test "resets a single error" <|
                \() ->
                    Exercise.init "abc"
                        |> Exercise.consume 'a'
                        |> Exercise.consume 'c'
                        -- |> Exercise.consume backspaceChar
                        |> Exercise.steps
                        |> Expect.equal
                            []
                            -- [ { content = "a", status = Completed, moveTo = Next }
                            -- , { content = "b", status = Current, moveTo = None }
                            -- , { content = "c", status = Waiting, moveTo = None }
                            -- , { content = "", status = End, moveTo = None }
                            -- ]
            ]
        -- , describe "isComplete"
        --     [ test "returns False for a new script" <|
        --         \() ->
        --             Exercise.init "a"
        --                 |> Exercise.isComplete
        --                 |> Expect.equal False
        --     , test "returns False with an error" <|
        --         \() ->
        --             Exercise.init "a"
        --                 |> Exercise.consume 'b'
        --                 |> Exercise.isComplete
        --                 |> Expect.equal False
        --     , test "returns True if at the end" <|
        --         \() ->
        --             Exercise.init "ab"
        --                 |> Exercise.consume 'a'
        --                 |> Exercise.consume 'b'
        --                 |> Exercise.isComplete
        --                 |> Expect.equal True
        --     ]
        -- , describe "accuracy"
        --     [ test "returns 0% for a single character with nothing typed" <|
        --         \() ->
        --             Exercise.init "a"
        --                 |> Exercise.accuracy
        --                 |> Expect.equal 0
        --     , test "returns 100% for a single character with only a single bad character typed" <|
        --         \() ->
        --             Exercise.init "a"
        --                 |> Exercise.consume 'b'
        --                 |> Exercise.accuracy
        --                 |> Expect.equal 100
        --     , test "returns 100% for a single character with a corrected single bad character typed" <|
        --         \() ->
        --             Exercise.init "a"
        --                 |> Exercise.consume 'b'
        --                 |> Exercise.consume backspaceChar
        --                 |> Exercise.consume 'a'
        --                 |> Exercise.accuracy
        --                 |> Expect.equal 50
        --     , test "returns 100% for a single character typed correctly" <|
        --         \() ->
        --             Exercise.init "a"
        --                 |> Exercise.consume 'a'
        --                 |> Exercise.accuracy
        --                 |> Expect.equal 100
        --     , test "returns 100% for a multiple characters typed correctly" <|
        --         \() ->
        --             Exercise.init "abc"
        --                 |> Exercise.consume 'a'
        --                 |> Exercise.consume 'b'
        --                 |> Exercise.consume 'c'
        --                 |> Exercise.accuracy
        --                 |> Expect.equal 100
        --     , test "returns 66.66% for a 2 corrected mistakes in a total of 4" <|
        --         \() ->
        --             Exercise.init "abcd"
        --                 |> Exercise.consume 'a'
        --                 |> Exercise.consume 'c'
        --                 |> Exercise.consume backspaceChar
        --                 |> Exercise.consume 'b'
        --                 |> Exercise.consume 'c'
        --                 |> Exercise.consume 'c'
        --                 |> Exercise.consume backspaceChar
        --                 |> Exercise.consume 'd'
        --                 |> Exercise.accuracy
        --                 |> (*) 100
        --                 |> truncate
        --                 |> toFloat
        --                 |> (flip (/) 100.0)
        --                 |> Expect.equal 66.66
        --     ]
        ]
