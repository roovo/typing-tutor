module Event exposing (Event, howManyTyped, timeTaken)

import Char


type alias Event =
    { char : Char
    , timeTaken : Int
    }


howManyTyped : List Event -> Float
howManyTyped =
    toFloat << List.length << typedEvents


timeTaken : List Event -> Float
timeTaken =
    toFloat << List.sum << List.map .timeTaken



-- PRIVATE FUNCTIONS


backspaceChar : Char
backspaceChar =
    Char.fromCode 8


timeTakenMins : List Event -> Float
timeTakenMins events =
    timeTaken events / 60000


typedEvents : List Event -> List Event
typedEvents =
    List.filter (\e -> e.char /= backspaceChar)
