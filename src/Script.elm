module Script exposing (Script, completed, current, init, remaining, tick)

import Html exposing (Html)
import Html.Attributes
import List.Zipper as Zipper exposing (Zipper)
import String


-- MODEL


type alias Script =
    { typing : Maybe (Zipper String)
    }


init : String -> Script
init toType =
    { typing =
        toType
            |> String.split ""
            |> Zipper.fromList
    }


current : Script -> String
current script =
    case script.typing of
        Nothing ->
            ""

        Just zippedString ->
            Zipper.current zippedString


completed : Script -> List String
completed script =
    case script.typing of
        Nothing ->
            []

        Just zippedString ->
            Zipper.before zippedString


remaining : Script -> List String
remaining script =
    case script.typing of
        Nothing ->
            []

        Just zippedString ->
            Zipper.after zippedString


tick : Char -> Script -> Script
tick char script =
    case script.typing of
        Nothing ->
            script

        Just zippedString ->
            { script | typing = Zipper.next zippedString }
