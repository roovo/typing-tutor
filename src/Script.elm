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
    script.typing
        |> Maybe.map Zipper.current
        |> Maybe.withDefault ""


completed : Script -> List String
completed script =
    script.typing
        |> Maybe.map Zipper.before
        |> Maybe.withDefault []


remaining : Script -> List String
remaining script =
    script.typing
        |> Maybe.map Zipper.after
        |> Maybe.withDefault []


tick : Char -> Script -> Script
tick char script =
    let
        charMatches zippedString =
            Zipper.current zippedString == String.fromChar char

        advance zippedString =
            if
                charMatches zippedString
                    && not (List.isEmpty (Zipper.after zippedString))
            then
                { script | typing = Zipper.next zippedString }
            else
                script
    in
        script.typing
            |> Maybe.map advance
            |> Maybe.withDefault script
