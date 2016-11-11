module View.Exercises.Result exposing (view)

import Attempt exposing (Attempt)
import Date
import Date.Extra
import Html exposing (Html)
import Html.Attributes
import Model exposing (Model)
import Msg exposing (Msg)


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.canvas
            [ Html.Attributes.id "attemptChart"
            , Html.Attributes.width 700
            , Html.Attributes.height 400
            ]
            []
        ]
