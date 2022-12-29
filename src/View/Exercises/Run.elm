module View.Exercises.Run exposing (view)

import Html exposing (Html)
import Html.Attributes exposing (id, style)
import Event
import Exercise exposing (Exercise, Printable, Style(..))
import Model exposing (Model)
import Msg exposing (Msg)
import Stopwatch


view : Model -> Html Msg
view model =
    Html.code
        []
        [ exerciseView model
        , Html.hr [] []
        , stopwatchView model
        ]


exerciseView : Model -> Html msg
exerciseView model =
    case model.exercise of
        Nothing ->
            Html.div [] []

        Just exercise ->
            Html.div []
                (List.append
                    (viewSteps exercise)
                    (viewResults exercise)
                )


stopwatchView : Model -> Html Msg
stopwatchView model =
    case model.exercise of
        Nothing ->
            Html.text ""

        Just exercise ->
            case Exercise.isComplete exercise of
                True ->
                    Html.text ""

                False ->
                    Html.p []
                        [ Html.text <|
                            Stopwatch.view <|
                                model.stopwatch.time
                        ]


viewSteps : Exercise -> List (Html msg)
viewSteps exercise =
    [ Html.pre
        []
        (Exercise.printables exercise
            |> List.map viewPrintable
        )
    ]


viewPrintable : Printable -> Html msg
viewPrintable printable =
    Html.span
        ( (case printable.style of
                Completed ->
                    [ style "color" "black"
                    ]

                Current ->
                    [ style "color" "black"
                    , style "background-color" "orange"
                    ]

                Error ->
                    [ style "color" "gray"
                    , style "background-color" "red"
                    ]

                Waiting ->
                    [ style "color" "gray"
                    ]
            )
            ++ if printable.style == Current then
                [ id "current" ]
               else
                []
        )
        [ viewPrintableContent printable.content ]


viewPrintableContent : String -> Html msg
viewPrintableContent content =
    -- if content == "\x0D" then
    if content == "\n" then
        Html.span []
            [ Html.text " "
            , Html.br [] []
            ]
    else
        Html.text content


viewResults : Exercise -> List (Html msg)
viewResults exercise =
    if Exercise.isComplete exercise then
        [ Html.hr [] []
        , Html.div []
            [ Html.p [] [ Html.text "Finished" ]
            , Html.p []
                [ Html.text <|
                    "Accuracy: "
                        ++ (percentage <| Exercise.accuracy exercise)
                , Html.br [] []
                , Html.text <|
                    "Speed: "
                        ++ String.fromInt (round <| Exercise.wpm exercise)
                        ++ " WPM"
                , Html.br [] []
                , Html.br [] []
                , Html.text <|
                    "Time taken: "
                        ++ Stopwatch.view (Event.timeTaken exercise.events)
                ]
            ]
        ]
    else
        []


percentage : Float -> String
percentage float =
    float
        |> (*) 100
        |> truncate
        |> toFloat
        |> (\f -> f / 100)
        |> String.fromFloat
        |> (\s -> String.append s "%")
