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
        , describe "makeCurrent"
            [ test "sets it to Current if it was Waiting" <|
                \() ->
                    Chunk.init "a"
                        |> Chunk.consume backspaceChar
                        |> Chunk.makeCurrent
                        |> .status
                        |> Expect.equal Current
            , test "sets it to Current if it was Completed" <|
                \() ->
                    Chunk.init "a"
                        |> Chunk.consume 'a'
                        |> Chunk.makeCurrent
                        |> .status
                        |> Expect.equal Current
            , test "leaves it as Current if that's what it was" <|
                \() ->
                    Chunk.init "a"
                        |> Chunk.consume 'a'
                        |> Chunk.makeCurrent
                        |> Chunk.makeCurrent
                        |> .status
                        |> Expect.equal Current
            , test "leaves it as End if that's what it was" <|
                \() ->
                    Chunk.end
                        |> Chunk.makeCurrent
                        |> .status
                        |> Expect.equal End
            , test "leaves it as Error 1 if that's what it was" <|
                \() ->
                    Chunk.init "a"
                        |> Chunk.consume 'b'
                        |> Chunk.makeCurrent
                        |> .status
                        |> Expect.equal (Error 1)
            ]
        ]
