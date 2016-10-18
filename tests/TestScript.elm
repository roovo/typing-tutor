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
        [ describe "chunks"
            [ test "returns an empty list for an empty string" <|
                \() ->
                    Script.init ""
                        |> Script.chunks
                        |> Expect.equal []
            , test "returns a single chunk for a single character string" <|
                \() ->
                    Script.init "a"
                        |> Script.chunks
                        |> Expect.equal [ { content = "a", status = Current, moveTo = None } ]
            , test "returns multiple chunks for a multi-character string" <|
                \() ->
                    Script.init "abc"
                        |> Script.chunks
                        |> Expect.equal
                            [ { content = "a", status = Current, moveTo = None }
                            , { content = "b", status = Waiting, moveTo = None }
                            , { content = "c", status = Waiting, moveTo = None }
                            ]
            ]
        , describe "tick"
            [ test "advances to the next character in the string" <|
                \() ->
                    Script.init "abc"
                        |> Script.tick 'a'
                        |> Script.chunks
                        |> Expect.equal
                            [ { content = "a", status = Completed, moveTo = Next }
                            , { content = "b", status = Current, moveTo = None }
                            , { content = "c", status = Waiting, moveTo = None }
                            ]
            , test "won't advance if the wrong character is given" <|
                \() ->
                    Script.init "abc"
                        |> Script.tick 'a'
                        |> Script.tick 'c'
                        |> Script.chunks
                        |> Expect.equal
                            [ { content = "a", status = Completed, moveTo = Next }
                            , { content = "b", status = Error 1, moveTo = None }
                            , { content = "c", status = Waiting, moveTo = None }
                            ]
            , test "won't advance past the end of the string" <|
                \() ->
                    Script.init "ab"
                        |> Script.tick 'a'
                        |> Script.tick 'b'
                        |> Script.chunks
                        |> Expect.equal
                            [ { content = "a", status = Completed, moveTo = Next }
                            , { content = "b", status = Completed, moveTo = Next }
                            ]
            ]
        , describe "tick with backspace"
            [ test "does nothing if at the start of a new string" <|
                \() ->
                    Script.init "abc"
                        |> Script.tick backspaceChar
                        |> Script.chunks
                        |> Expect.equal
                            [ { content = "a", status = Current, moveTo = Previous }
                            , { content = "b", status = Waiting, moveTo = None }
                            , { content = "c", status = Waiting, moveTo = None }
                            ]
            , test "goes back a character if beyond the start" <|
                \() ->
                    Script.init "abc"
                        |> Script.tick 'a'
                        |> Script.tick 'b'
                        |> Script.tick backspaceChar
                        |> Script.chunks
                        |> Expect.equal
                            [ { content = "a", status = Completed, moveTo = Next }
                            , { content = "b", status = Current, moveTo = Next }
                            , { content = "c", status = Waiting, moveTo = Previous }
                            ]
            , test "resets a single error" <|
                \() ->
                    Script.init "abc"
                        |> Script.tick 'a'
                        |> Script.tick 'c'
                        |> Script.tick backspaceChar
                        |> Script.chunks
                        |> Expect.equal
                            [ { content = "a", status = Completed, moveTo = Next }
                            , { content = "b", status = Current, moveTo = None }
                            , { content = "c", status = Waiting, moveTo = None }
                            ]
            ]
        ]
