module Chunk exposing (Chunk, Status(..), init, parseChar)

import Char
import String


backspaceCode =
    8


type alias Chunk =
    { content : String
    , status : Status
    , next : Int
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
    , next = 0
    }


parseChar : Char -> Chunk -> Chunk
parseChar char chunk =
    let
        matchingChar =
            chunk.content == String.fromChar char

        backSpace =
            Char.toCode char == backspaceCode
    in
        if matchingChar && isErrorFree chunk then
            { chunk | status = Completed, next = 1 }
        else if backSpace && isErrorFree chunk then
            { chunk | status = Waiting, next = -1 }
        else if backSpace then
            { chunk | status = removeError chunk.status, next = 0 }
        else
            { chunk | status = addError chunk.status, next = 0 }


isErrorFree : Chunk -> Bool
isErrorFree chunk =
    case chunk.status of
        Error _ ->
            False

        _ ->
            True


addError : Status -> Status
addError status =
    case status of
        Error count ->
            Error (count + 1)

        _ ->
            Error 1


removeError : Status -> Status
removeError status =
    case status of
        Error 1 ->
            Waiting

        Error count ->
            Error (count - 1)

        _ ->
            status
