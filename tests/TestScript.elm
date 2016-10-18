module TestScript exposing (..)

import Char
import Chunk exposing (Chunk, Direction(..), Status(..))
import Expect
import Script exposing (Script)
import Test exposing (..)


backspaceChar =
    (Char.fromCode 8)


script : Test
script =
    describe "Script"
        [ describe "toList"
            [ test "returns a list with only the end item for an empty string" <|
                \() ->
                    Script.init ""
                        |> Script.toList
                        |> Expect.equal [ { content = "", status = End, moveTo = None } ]
            , test "returns multiple chunks for a multi-character string" <|
                \() ->
                    Script.init "abc"
                        |> Script.toList
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
                    Script.init "abc"
                        |> Script.consume 'a'
                        |> Script.toList
                        |> Expect.equal
                            [ { content = "a", status = Completed, moveTo = Next }
                            , { content = "b", status = Current, moveTo = None }
                            , { content = "c", status = Waiting, moveTo = None }
                            , { content = "", status = End, moveTo = None }
                            ]
            , test "won't advance if the wrong character is given" <|
                \() ->
                    Script.init "abc"
                        |> Script.consume 'a'
                        |> Script.consume 'c'
                        |> Script.toList
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
                    Script.init "abc"
                        |> Script.consume backspaceChar
                        |> Script.toList
                        |> Expect.equal
                            [ { content = "a", status = Current, moveTo = Previous }
                            , { content = "b", status = Waiting, moveTo = None }
                            , { content = "c", status = Waiting, moveTo = None }
                            , { content = "", status = End, moveTo = None }
                            ]
            , test "goes back a character if beyond the start" <|
                \() ->
                    Script.init "abc"
                        |> Script.consume 'a'
                        |> Script.consume 'b'
                        |> Script.consume backspaceChar
                        |> Script.toList
                        |> Expect.equal
                            [ { content = "a", status = Completed, moveTo = Next }
                            , { content = "b", status = Current, moveTo = Next }
                            , { content = "c", status = Waiting, moveTo = Previous }
                            , { content = "", status = End, moveTo = None }
                            ]
            , test "resets a single error" <|
                \() ->
                    Script.init "abc"
                        |> Script.consume 'a'
                        |> Script.consume 'c'
                        |> Script.consume backspaceChar
                        |> Script.toList
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
                    Script.init "a"
                        |> Script.isComplete
                        |> Expect.equal False
            , test "returns False with an error" <|
                \() ->
                    Script.init "a"
                        |> Script.consume 'b'
                        |> Script.isComplete
                        |> Expect.equal False
            , test "returns True if at the end" <|
                \() ->
                    Script.init "ab"
                        |> Script.consume 'a'
                        |> Script.consume 'b'
                        |> Script.isComplete
                        |> Expect.equal True
            ]
        ]
