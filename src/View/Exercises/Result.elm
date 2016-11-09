module View.Exercises.Result exposing (view)

import Attempt exposing (Attempt)
import Html exposing (Html)
import Model exposing (Model)
import Msg exposing (Msg)


view : Model -> Html Msg
view model =
    viewAttemptsTable model


viewAttemptsTable : Model -> Html Msg
viewAttemptsTable model =
    Html.table []
        [ Html.thead []
            [ Html.tr []
                [ Html.th [] [ Html.text "When" ]
                , Html.th [] [ Html.text "WPM" ]
                , Html.th [] [ Html.text "Accuracy" ]
                ]
            ]
        , Html.tbody []
            (List.map viewAttemptRow model.attempts)
        ]


viewAttemptRow : Attempt -> Html Msg
viewAttemptRow attempt =
    Html.tr []
        [ Html.td [] [ Html.text (toString attempt.completedAt) ]
        , Html.td [] [ Html.text (toString attempt.wpm) ]
        , Html.td [] [ Html.text (toString attempt.accuracy) ]
        ]
