module View.Exercises.List exposing (view)

import Html exposing (Html)
import Html.Attributes
import Model exposing (Model)
import Msg exposing (Msg)


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.a
            [ Html.Attributes.href "/run"
            ]
            [ Html.text "run"
            ]
        ]
