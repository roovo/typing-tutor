module TestChunk exposing (..)

import Char
import Chunk exposing (Chunk, Status(..))
import Expect
import Test exposing (..)


backspaceChar =
    (Char.fromCode 8)


chunk : Test
chunk =
    describe "Chunk"
        [ describe "init"
            [ test "returns a chunk with a status of Waiting and no cursorDelta" <|
                \() ->
                    Chunk.init "foo"
                        |> Expect.equal { content = "foo", status = Waiting, next = 0 }
            ]
        , describe "parseChar"
            [ describe "no Errors"
                [ test "matching char returns status = Completed, next = 1" <|
                    \() ->
                        Chunk.init "a"
                            |> Chunk.parseChar 'a'
                            |> Expect.equal { content = "a", status = Completed, next = 1 }
                , test "backspace returns status = Waiting, next = -1" <|
                    \() ->
                        Chunk.init "a"
                            |> Chunk.parseChar backspaceChar
                            |> Expect.equal { content = "a", status = Waiting, next = -1 }
                , test "non-matching returns status = Error 1, next = 0" <|
                    \() ->
                        Chunk.init "a"
                            |> Chunk.parseChar 'b'
                            |> Expect.equal { content = "a", status = Error 1, next = 0 }
                ]
            , describe "with Error 1 (single error)"
                [ test "matching char returns status = Error 2, next = 0" <|
                    \() ->
                        Chunk.init "a"
                            |> Chunk.parseChar 'b'
                            |> Chunk.parseChar 'a'
                            |> Expect.equal { content = "a", status = Error 2, next = 0 }
                , test "backspace returns status = Waiting, next = 0" <|
                    \() ->
                        Chunk.init "a"
                            |> Chunk.parseChar 'b'
                            |> Chunk.parseChar backspaceChar
                            |> Expect.equal { content = "a", status = Waiting, next = 0 }
                , test "non-matching returns status = Error 2, next = 0" <|
                    \() ->
                        Chunk.init "a"
                            |> Chunk.parseChar 'b'
                            |> Chunk.parseChar 'b'
                            |> Expect.equal { content = "a", status = Error 2, next = 0 }
                ]
            , describe "with Error 2 (multiple errora)"
                [ test "matching char returns status = Error 3, next = 0" <|
                    \() ->
                        Chunk.init "a"
                            |> Chunk.parseChar 'b'
                            |> Chunk.parseChar 'b'
                            |> Chunk.parseChar 'a'
                            |> Expect.equal { content = "a", status = Error 3, next = 0 }
                , test "backspace returns status = Error 1, next = 0" <|
                    \() ->
                        Chunk.init "a"
                            |> Chunk.parseChar 'b'
                            |> Chunk.parseChar 'b'
                            |> Chunk.parseChar backspaceChar
                            |> Expect.equal { content = "a", status = Error 1, next = 0 }
                , test "non-matching returns status = Error 3, next = 0" <|
                    \() ->
                        Chunk.init "a"
                            |> Chunk.parseChar 'b'
                            |> Chunk.parseChar 'b'
                            |> Chunk.parseChar 'b'
                            |> Expect.equal { content = "a", status = Error 3, next = 0 }
                ]
            ]
        ]
