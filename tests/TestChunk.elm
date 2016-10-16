module TestChunk exposing (..)

import Test exposing (..)
import Expect
import Chunk exposing (Chunk, Status(..))


chunk : Test
chunk =
    describe "Chunk"
        [ describe "init"
            [ test "returns a chunk with a status of Waiting" <|
                \() ->
                    Chunk.init "foo"
                        |> Expect.equal { content = "foo", status = Waiting }
            ]
        , describe "updateStatus"
            [ test "sets the status to Complete if the char is the same as the content" <|
                \() ->
                    Chunk.init "a"
                        |> Chunk.updateStatus 'a'
                        |> Expect.equal { content = "a", status = Completed }
            , test "sets the status to Error if the char is NOT the same as the content" <|
                \() ->
                    Chunk.init "a"
                        |> Chunk.updateStatus 'b'
                        |> Expect.equal { content = "a", status = Error 1 }
            ]
        , describe "resetStatus"
            [ test "resets the status to Waiting" <|
                \() ->
                    Chunk.init "a"
                        |> Chunk.updateStatus 'b'
                        |> Chunk.resetStatus
                        |> Expect.equal { content = "a", status = Waiting }
            ]
        , describe "isCorrect"
            [ test "returns False if the status is Waiting" <|
                \() ->
                    Chunk.init "a"
                        |> Chunk.isCorrect
                        |> Expect.equal False
            , test "returns True if the status is Completed" <|
                \() ->
                    Chunk.init "a"
                        |> Chunk.updateStatus 'a'
                        |> Chunk.isCorrect
                        |> Expect.equal True
            ]
        ]
