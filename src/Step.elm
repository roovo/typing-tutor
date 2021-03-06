module Step
    exposing
        ( Step
        , toString
        , init
        , initEnd
        , initSkip
        , isEnd
        , isSkipable
        , isSkipableWhitespace
        , isTypeable
        , isTypeableEnter
        , matchesTyped
        )

import Char
import String


backspaceCode : Int
backspaceCode =
    8


enterChar : Char
enterChar =
    (Char.fromCode 13)


type Step
    = Typeable Char
    | Skip String
    | End


init : Char -> Step
init char =
    Typeable char


initSkip : String -> Step
initSkip string =
    Skip string


initEnd : Step
initEnd =
    End


toString : Step -> String
toString step =
    case step of
        Typeable char ->
            String.fromChar char

        Skip string ->
            string

        End ->
            ""


matchesTyped : Char -> Step -> Bool
matchesTyped char step =
    case step of
        Typeable actual ->
            actual == char

        _ ->
            False


isEnd : Step -> Bool
isEnd step =
    case step of
        End ->
            True

        _ ->
            False


isSkipable : Step -> Bool
isSkipable step =
    case step of
        Skip _ ->
            True

        _ ->
            False


isSkipableWhitespace : Step -> Bool
isSkipableWhitespace step =
    case step of
        Skip string ->
            String.length (String.trim string) == 0

        _ ->
            False


isTypeable : Step -> Bool
isTypeable step =
    case step of
        Typeable _ ->
            True

        _ ->
            False


isTypeableEnter : Step -> Bool
isTypeableEnter step =
    case step of
        Typeable char ->
            char == enterChar

        _ ->
            False
