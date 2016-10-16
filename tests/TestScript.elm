module TestScript exposing (..)

import Test exposing (..)
import Expect
import Script exposing (Script)
import Chunk exposing (Chunk, Status(..))


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
                        |> Expect.equal [ { content = "a", status = Current } ]
            , test "returns multiple chunks for a multi-character string" <|
                \() ->
                    Script.init "abc"
                        |> Script.chunks
                        |> Expect.equal
                            [ { content = "a", status = Current }
                            , { content = "b", status = Waiting }
                            , { content = "c", status = Waiting }
                            ]
            ]
        , describe "tick"
            [ test "advances to the next character in the string" <|
                \() ->
                    Script.init "abc"
                        |> Script.tick 'a'
                        |> Script.chunks
                        |> Expect.equal
                            [ { content = "a", status = Completed }
                            , { content = "b", status = Current }
                            , { content = "c", status = Waiting }
                            ]
            , test "won't advance if the wrong character is given" <|
                \() ->
                    Script.init "abc"
                        |> Script.tick 'a'
                        |> Script.tick 'c'
                        |> Script.chunks
                        |> Expect.equal
                            [ { content = "a", status = Completed }
                            , { content = "b", status = Error 1 }
                            , { content = "c", status = Waiting }
                            ]
            , test "won't advance past the end of the string" <|
                \() ->
                    Script.init "ab"
                        |> Script.tick 'a'
                        |> Script.tick 'b'
                        |> Script.chunks
                        |> Expect.equal
                            [ { content = "a", status = Completed }
                            , { content = "b", status = Completed }
                            ]
            ]
        , describe "backspace"
            [ test "does nothing if at the start of a new string" <|
                \() ->
                    Script.init "abc"
                        |> Script.backspace
                        |> Script.chunks
                        |> Expect.equal
                            [ { content = "a", status = Current }
                            , { content = "b", status = Waiting }
                            , { content = "c", status = Waiting }
                            ]
            , test "goes back a character if beyond the start" <|
                \() ->
                    Script.init "abc"
                        |> Script.tick 'a'
                        |> Script.tick 'b'
                        |> Script.backspace
                        |> Script.chunks
                        |> Expect.equal
                            [ { content = "a", status = Completed }
                            , { content = "b", status = Current }
                            , { content = "c", status = Waiting }
                            ]
            ]
        ]
