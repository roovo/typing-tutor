module Chunk exposing (Chunk, Status(..), initChunk, isCorrect, resetStatus, updateStatus)

import String


type alias Chunk =
    { text : String
    , status : Status
    }


type Status
    = Waiting
    | Error
    | Current
    | Completed


initChunk : String -> Chunk
initChunk string =
    { text = string
    , status = Waiting
    }


resetStatus : Chunk -> Chunk
resetStatus chunk =
    { chunk | status = Waiting }


updateStatus : Char -> Chunk -> Chunk
updateStatus char chunk =
    if chunk.text == String.fromChar char then
        { chunk | status = Completed }
    else
        { chunk | status = Error }


isCorrect : Chunk -> Bool
isCorrect chunk =
    chunk.status == Completed
