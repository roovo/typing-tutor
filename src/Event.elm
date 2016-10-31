module Event exposing (Event, accuracy, timeTaken, wpm)

import Char
import String


type alias Event =
    { expected : String
    , actual : String
    , timeTaken : Int
    }


accuracy : List Event -> Float
accuracy events =
    if typedCharacterCount events == 0 then
        0
    else
        (toFloat <| exerciseCharacterCount events)
            / (toFloat <| typedCharacterCount events)
            * 100


timeTaken : List Event -> Int
timeTaken events =
    events
        |> List.map .timeTaken
        |> List.sum


wpm : List Event -> Float
wpm events =
    let
        timeMins =
            toFloat (timeTaken events) / 60000
    in
        if timeMins == 0 then
            0
        else
            (toFloat (exerciseCharacterCount events) / 5) / timeMins



-- PRIVATE FUNCTIONS


backspaceChar =
    String.fromChar (Char.fromCode 8)


matchedEvents : List Event -> List Event
matchedEvents =
    List.filter (\e -> e.actual == e.expected)


typedEvents : List Event -> List Event
typedEvents =
    List.filter (\e -> e.actual /= backspaceChar)


exerciseCharacterCount : List Event -> Int
exerciseCharacterCount events =
    List.length (matchedEvents events)


typedCharacterCount : List Event -> Int
typedCharacterCount events =
    List.length (typedEvents events)
