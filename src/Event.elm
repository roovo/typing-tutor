module Event exposing (Event, howManyTyped, timeTaken, wpm)

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


wpm : List Event -> Float
wpm events =
    case timeTaken events of
        0 ->
            0

        n ->
            howManyWords events / n * 60000



-- PRIVATE FUNCTIONS


lettersPerWord =
    5


backspaceChar =
    String.fromChar << Char.fromCode <| 8


howManyWords : List Event -> Float
howManyWords events =
    ((howManyCharacters events) / lettersPerWord)


timeTakenMins : List Event -> Float
timeTakenMins events =
    timeTaken events / 60000


matchedEvents : List Event -> List Event
matchedEvents =
    List.filter (\e -> e.actual == e.expected)


typedEvents : List Event -> List Event
typedEvents =
    List.filter (\e -> e.actual /= backspaceChar)


howManyCharacters : List Event -> Float
howManyCharacters =
    toFloat << List.length << matchedEvents
