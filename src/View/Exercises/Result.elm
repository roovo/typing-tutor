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
        [ viewAttemptsTable model
        , Html.canvas
            [ Html.Attributes.id "attemptChart"
            , Html.Attributes.width 700
            , Html.Attributes.height 400
            ]
            []
        ]


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
        [ Html.td [] [ Html.text (Date.Extra.toFormattedString "EEE ddd MMM @ HH:mm" <| Date.fromTime attempt.completedAt) ]
        , Html.td [] [ Html.text (toString <| round attempt.wpm) ]
        , Html.td [] [ Html.text <| percentage attempt.accuracy ]
        ]


percentage : Float -> String
percentage float =
    float
        |> (*) 100
        |> truncate
        |> toFloat
        |> (flip (/) 100.0)
        |> toString
        |> (flip (++) "%")
