module View.Exercises.List exposing (view)

import Exercise exposing (Exercise)
import Html exposing (Html)
import Html.Attributes
import Model exposing (Model)
import Msg exposing (Msg)


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.h2 [] [ Html.text "Available exercies" ]
        , Html.div []
            [ exercisesTable model
            ]
        , Html.a
            [ Html.Attributes.href "/run"
            ]
            [ Html.text "run"
            ]
        ]


exercisesTable : Model -> Html Msg
exercisesTable model =
    Html.table []
        [ Html.tbody []
            (List.map exerciseRow model.exercises)
        ]


exerciseRow : Exercise -> Html Msg
exerciseRow exercise =
    Html.tr []
        [ Html.td [] [ Html.text exercise.title ]
        ]
