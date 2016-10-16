module Script exposing (Script, init)

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
