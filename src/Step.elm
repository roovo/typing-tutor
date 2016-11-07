module Step
    exposing
        ( Step
        , Direction(..)
        , Status(..)
        , init
        , initEnd
        , initSkip
        , isTypeable
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
    = Typeable
    | Skip
    | End


type Direction
    = Next
    | Previous
    | None


init : String -> Step
init string =
    { content = string
    , status = Typeable
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


isTypeable : Step -> Bool
isTypeable step =
    step.status == Typeable
