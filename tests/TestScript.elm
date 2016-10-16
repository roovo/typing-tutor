module TestScript exposing (..)

import Char
import Chunk exposing (Chunk, Status(..))
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
                        |> Expect.equal [ { content = "a", status = Current, next = 0 } ]
            , test "returns multiple chunks for a multi-character string" <|
                \() ->
                    Script.init "abc"
                        |> Script.chunks
                        |> Expect.equal
                            [ { content = "a", status = Current, next = 0 }
                            , { content = "b", status = Waiting, next = 0 }
                            , { content = "c", status = Waiting, next = 0 }
                            ]
            ]
        , describe "tick"
            [ test "advances to the next character in the string" <|
                \() ->
                    Script.init "abc"
                        |> Script.tick 'a'
                        |> Script.chunks
                        |> Expect.equal
                            [ { content = "a", status = Completed, next = 1 }
                            , { content = "b", status = Current, next = 0 }
                            , { content = "c", status = Waiting, next = 0 }
                            ]
            , test "won't advance if the wrong character is given" <|
                \() ->
                    Script.init "abc"
                        |> Script.tick 'a'
                        |> Script.tick 'c'
                        |> Script.chunks
                        |> Expect.equal
                            [ { content = "a", status = Completed, next = 1 }
                            , { content = "b", status = Error 1, next = 0 }
                            , { content = "c", status = Waiting, next = 0 }
                            ]
            , test "won't advance past the end of the string" <|
                \() ->
                    Script.init "ab"
                        |> Script.tick 'a'
                        |> Script.tick 'b'
                        |> Script.chunks
                        |> Expect.equal
                            [ { content = "a", status = Completed, next = 1 }
                            , { content = "b", status = Completed, next = 1 }
                            ]
            ]
        , describe "tick with backspace"
            [ test "does nothing if at the start of a new string" <|
                \() ->
                    Script.init "abc"
                        |> Script.tick backspaceChar
                        |> Script.chunks
                        |> Expect.equal
                            [ { content = "a", status = Current, next = -1 }
                            , { content = "b", status = Waiting, next = 0 }
                            , { content = "c", status = Waiting, next = 0 }
                            ]
            , test "goes back a character if beyond the start" <|
                \() ->
                    Script.init "abc"
                        |> Script.tick 'a'
                        |> Script.tick 'b'
                        |> Script.tick backspaceChar
                        |> Script.chunks
                        |> Expect.equal
                            [ { content = "a", status = Completed, next = 1 }
                            , { content = "b", status = Current, next = 1 }
                            , { content = "c", status = Waiting, next = -1 }
                            ]
            , test "resets a single error" <|
                \() ->
                    Script.init "abc"
                        |> Script.tick 'a'
                        |> Script.tick 'c'
                        |> Script.tick backspaceChar
                        |> Script.chunks
                        |> Expect.equal
                            [ { content = "a", status = Completed, next = 1 }
                            , { content = "b", status = Current, next = 0 }
                            , { content = "c", status = Waiting, next = 0 }
                            ]
            ]
        ]
