module Chunk exposing (Chunk, Status(..), init, isCorrect, resetStatus, updateStatus)

import String


type alias Chunk =
    { content : String
    , status : Status
    }


type Status
    = Waiting
    | Error Int
    | Current
    | Completed


init : String -> Chunk
init string =
    { content = string
    , status = Waiting
    }


resetStatus : Chunk -> Chunk
resetStatus chunk =
    { chunk | status = Waiting }


updateStatus : Char -> Chunk -> Chunk
updateStatus char chunk =
    if chunk.content == String.fromChar char then
        { chunk | status = Completed }
    else
        { chunk | status = Error 1 }


isCorrect : Chunk -> Bool
isCorrect chunk =
    chunk.status == Completed
