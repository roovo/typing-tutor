module View.Exercises.Run exposing (view)

import Html exposing (Html)
import Html.Attributes
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
                        ++ toString (round <| Exercise.wpm exercise)
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
        |> (flip (/) 100.0)
        |> toString
        |> (flip (++) "%")


viewPrintable : Printable -> Html msg
viewPrintable printable =
    Html.span
        [ Html.Attributes.style
            (case printable.style of
                Completed ->
                    [ ( "color", "black" )
                    ]

                Current ->
                    [ ( "color", "black" )
                    , ( "background-color", "orange" )
                    ]

                Error ->
                    [ ( "color", "gray" )
                    , ( "background-color", "red" )
                    ]

                Waiting ->
                    [ ( "color", "gray" )
                    ]
            )
        ]
        [ viewPrintableContent printable.content ]


viewPrintableContent : String -> Html msg
viewPrintableContent content =
    if content == "\x0D" then
        Html.span []
            [ Html.text " "
            , Html.br [] []
            ]
    else
        Html.text content
