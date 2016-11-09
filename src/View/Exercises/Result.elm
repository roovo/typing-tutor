module View.Exercises.Result exposing (view)

import Html exposing (Html)
import Model exposing (Model)
import Msg exposing (Msg)


view : Model -> Html Msg
view model =
    Html.text "results"
