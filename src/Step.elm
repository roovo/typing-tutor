module Step
    exposing
        ( Step
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
    }


type Status
    = Typeable
    | Skip
    | End


init : String -> Step
init string =
    { content = string
    , status = Typeable
    }


initSkip : String -> Step
initSkip string =
    { content = string
    , status = Skip
    }


initEnd : Step
initEnd =
    { content = ""
    , status = End
    }


isTypeable : Step -> Bool
isTypeable step =
    step.status == Typeable
