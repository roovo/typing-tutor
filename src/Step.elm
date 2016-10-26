module Step
    exposing
        ( Step
        , Direction(..)
        , Status(..)
        , consume
        , init
        , initEnd
        , initSkip
        , isNotSkipped
        , makeCurrent
        )

import Char
import String


backspaceCode =
    8


type alias Step =
    { content : String
    , status : Status
    , moveTo : Direction
    }


type Status
    = Waiting
    | Error Int
    | Current
    | Completed
    | Skip
    | End


type Direction
    = Next
    | Previous
    | None


init : String -> Step
init string =
    { content = string
    , status = Waiting
    , moveTo = None
    }


initSkip : String -> Step
initSkip string =
    { content = string
    , status = Skip
    , moveTo = None
    }


initEnd : Step
initEnd =
    { content = ""
    , status = End
    , moveTo = None
    }


consume : Char -> Step -> Step
consume char step =
    let
        matchingChar =
            step.content == String.fromChar char

        backSpace =
            Char.toCode char == backspaceCode
    in
        if matchingChar && isErrorFree step then
            { step | status = Completed, moveTo = Next }
        else if step.status == End then
            { step | status = End, moveTo = None }
        else if backSpace && isErrorFree step then
            { step | status = Waiting, moveTo = Previous }
        else if backSpace then
            { step | status = removeError step.status, moveTo = None }
        else
            { step | status = addError step.status, moveTo = None }


makeCurrent : Step -> Step
makeCurrent step =
    case step.status of
        Waiting ->
            { step | status = Current }

        Completed ->
            { step | status = Current }

        _ ->
            step


isNotSkipped : Step -> Bool
isNotSkipped step =
    step.status /= Skip



-- PRIVATE FUNCTIONS


isErrorFree : Step -> Bool
isErrorFree step =
    case step.status of
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
