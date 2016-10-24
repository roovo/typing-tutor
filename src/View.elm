module View exposing (view)

import Exercise
import ExerciseView
import Html exposing (Html)
import Model exposing (Model)
import Msg exposing (Msg)
import Stopwatch


view : Model -> Html Msg
view model =
    Html.div
        []
        [ Html.code
            []
            [ ExerciseView.view model.exercise
            , Html.hr [] []
            , stopwatchView model
            ]
        ]


stopwatchView : Model -> Html Msg
stopwatchView model =
    case Exercise.isComplete model.exercise of
        True ->
            Html.text ""

        False ->
            Html.p []
                [ Html.text <|
                    Stopwatch.view model.stopwatch.time
                ]
