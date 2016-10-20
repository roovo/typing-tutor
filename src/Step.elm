module Step exposing (Step, Direction(..), Status(..), consume, end, error, init, makeCurrent)

import Char
import String


backspaceCode =
    8


backspaceChar =
    (Char.fromCode 8)


type alias Step =
    { content : String
    , status : Status
    , moveTo : Direction
    }


type Status
    = Waiting
    | Error Char
    | Current
    | Completed
    | End


type Direction
    = None
    | Next
    | Previous
    | NewBranch


init : String -> Step
init string =
    { content = string
    , status = Waiting
    , moveTo = None
    }


end : Step
end =
    { content = ""
    , status = End
    , moveTo = None
    }


error : Char -> Step
error char =
    { content = String.fromChar backspaceChar
    , status = Error char
    , moveTo = None
    }


consume : Char -> Step -> Step
consume char step =
    if isBackspace char then
        { step | status = Waiting, moveTo = Previous }
    else if isMatching char step then
        { step | status = Completed, moveTo = Next }
    else
        { step | status = Waiting, moveTo = NewBranch }



makeCurrent : Step -> Step
makeCurrent step =
    case step.status of
        Waiting ->
            { step | status = Current }

        Completed ->
            { step | status = Current }

        _ ->
            -- { step | status = Current }
            step



-- PRIVATE FUNCTIONS


isMatching : Char -> Step -> Bool
isMatching char step =
    step.content == String.fromChar char


isBackspace : Char -> Bool
isBackspace char =
    Char.toCode char == backspaceCode
