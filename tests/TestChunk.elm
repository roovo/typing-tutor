module TestChunk exposing (..)

import Char
import Chunk exposing (Chunk, Direction(..), Status(..))
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
                        |> Expect.equal { content = "foo", status = Waiting, moveTo = None }
            ]
        , describe "consume"
            [ describe "no Errors"
                [ test "matching char returns status = Completed, moveTo = Next" <|
                    \() ->
                        Chunk.init "a"
                            |> Chunk.consume 'a'
                            |> Expect.equal { content = "a", status = Completed, moveTo = Next }
                , test "backspace returns status = Waiting, moveTo = Previous" <|
                    \() ->
                        Chunk.init "a"
                            |> Chunk.consume backspaceChar
                            |> Expect.equal { content = "a", status = Waiting, moveTo = Previous }
                , test "non-matching returns status = Error 1, moveTo = None" <|
                    \() ->
                        Chunk.init "a"
                            |> Chunk.consume 'b'
                            |> Expect.equal { content = "a", status = Error 1, moveTo = None }
                ]
            , describe "with Error 1 (single error)"
                [ test "matching char returns status = Error 2, moveTo = None" <|
                    \() ->
                        Chunk.init "a"
                            |> Chunk.consume 'b'
                            |> Chunk.consume 'a'
                            |> Expect.equal { content = "a", status = Error 2, moveTo = None }
                , test "backspace returns status = Waiting, moveTo = None" <|
                    \() ->
                        Chunk.init "a"
                            |> Chunk.consume 'b'
                            |> Chunk.consume backspaceChar
                            |> Expect.equal { content = "a", status = Waiting, moveTo = None }
                , test "non-matching returns status = Error 2, moveTo = None" <|
                    \() ->
                        Chunk.init "a"
                            |> Chunk.consume 'b'
                            |> Chunk.consume 'b'
                            |> Expect.equal { content = "a", status = Error 2, moveTo = None }
                ]
            , describe "with Error 2 (multiple errora)"
                [ test "matching char returns status = Error 3, moveTo = None" <|
                    \() ->
                        Chunk.init "a"
                            |> Chunk.consume 'b'
                            |> Chunk.consume 'b'
                            |> Chunk.consume 'a'
                            |> Expect.equal { content = "a", status = Error 3, moveTo = None }
                , test "backspace returns status = Error 1, moveTo = None" <|
                    \() ->
                        Chunk.init "a"
                            |> Chunk.consume 'b'
                            |> Chunk.consume 'b'
                            |> Chunk.consume backspaceChar
                            |> Expect.equal { content = "a", status = Error 1, moveTo = None }
                , test "non-matching returns status = Error 3, moveTo = None" <|
                    \() ->
                        Chunk.init "a"
                            |> Chunk.consume 'b'
                            |> Chunk.consume 'b'
                            |> Chunk.consume 'b'
                            |> Expect.equal { content = "a", status = Error 3, moveTo = None }
                ]
            ]
        ]
