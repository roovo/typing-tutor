module Event exposing (Event, howManyTyped, timeTaken)

import Char
import String


type alias Event =
    { expected : String
    , actual : String
    , timeTaken : Int
    }


howManyTyped : List Event -> Float
howManyTyped =
    toFloat << List.length << typedEvents


timeTaken : List Event -> Float
timeTaken =
    toFloat << List.sum << List.map .timeTaken



-- PRIVATE FUNCTIONS


backspaceChar =
    String.fromChar << Char.fromCode <| 8


timeTakenMins : List Event -> Float
timeTakenMins events =
    timeTaken events / 60000


typedEvents : List Event -> List Event
typedEvents =
    List.filter (\e -> e.actual /= backspaceChar)
