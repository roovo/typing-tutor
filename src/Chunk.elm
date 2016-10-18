module Chunk exposing (Chunk, Direction(..), Status(..), consume, end, init, makeCurrent)

import Char
import String


backspaceCode =
    8


type alias Chunk =
    { content : String
    , status : Status
    , moveTo : Direction
    }


type Status
    = Waiting
    | Error Int
    | Current
    | Completed
    | End


type Direction
    = Next
    | Previous
    | None


init : String -> Chunk
init string =
    { content = string
    , status = Waiting
    , moveTo = None
    }


end : Chunk
end =
    { content = ""
    , status = End
    , moveTo = None
    }


consume : Char -> Chunk -> Chunk
consume char chunk =
    let
        matchingChar =
            chunk.content == String.fromChar char

        backSpace =
            Char.toCode char == backspaceCode
    in
        if matchingChar && isErrorFree chunk then
            { chunk | status = Completed, moveTo = Next }
        else if chunk.status == End then
            { chunk | status = End, moveTo = None }
        else if backSpace && isErrorFree chunk then
            { chunk | status = Waiting, moveTo = Previous }
        else if backSpace then
            { chunk | status = removeError chunk.status, moveTo = None }
        else
            { chunk | status = addError chunk.status, moveTo = None }


makeCurrent : Chunk -> Chunk
makeCurrent chunk =
    case chunk.status of
        Waiting ->
            { chunk | status = Current }

        Completed ->
            { chunk | status = Current }

        _ ->
            chunk


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
