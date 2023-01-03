module Event exposing
    ( Event
    , encoder
    , howManyTyped
    , timeTaken
    )

import Char
import Json.Encode as JE


type alias Event =
    { char : Char
    , timeTaken : Int
    }


howManyTyped : List Event -> Int
howManyTyped =
    List.length << typedEvents


timeTaken : List Event -> Float
timeTaken =
    toFloat << List.sum << List.map .timeTaken


encoder : Event -> JE.Value
encoder event =
    JE.list JE.string [ String.fromChar event.char, String.fromInt event.timeTaken ]



-- PRIVATE


backspaceChar : Char
backspaceChar =
    Char.fromCode 8


typedEvents : List Event -> List Event
typedEvents =
    List.filter (\e -> e.char /= backspaceChar)
