module Event exposing (Event, howManyTyped, timeTaken)

import Char


type alias Event =
    { char : Char
    , timeTaken : Int
    }


howManyTyped : List Event -> Int
howManyTyped =
    List.length << typedEvents


timeTaken : List Event -> Int
timeTaken =
    List.sum << List.map .timeTaken



-- PRIVATE


backspaceChar : Char
backspaceChar =
    Char.fromCode 8


timeTakenMins : List Event -> Int
timeTakenMins events =
    timeTaken events // 60000


typedEvents : List Event -> List Event
typedEvents =
    List.filter (\e -> e.char /= backspaceChar)
