module Step
    exposing
        ( Step
        , Direction(..)
        , Status(..)
        , init
        , initEnd
        , initSkip
        , isTypable
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


isTypable : Step -> Bool
isTypable step =
    not <| List.member step.status [ Skip, End ]
