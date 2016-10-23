module ExerciseView exposing (view)

import Html exposing (Html)
import Html.Attributes
import Exercise exposing (Exercise)
import Step exposing (Step, Status(..))
import Stopwatch
import Time exposing (Time)


view : Exercise -> Html msg
view exercise =
    Html.div []
        (List.append
            (viewSteps exercise)
            (viewResults exercise)
        )


viewSteps : Exercise -> List (Html msg)
viewSteps exercise =
    [ Html.code
        []
        (Exercise.steps exercise
            |> List.map viewStep
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
                        ++ Stopwatch.view exercise.timeTaken
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


viewStep : Step -> Html msg
viewStep step =
    Html.span
        [ Html.Attributes.style
            (case step.status of
                Completed ->
                    [ ( "color", "black" )
                    ]

                Current ->
                    [ ( "color", "black" )
                    , ( "background-color", "orange" )
                    ]

                Error _ ->
                    [ ( "color", "gray" )
                    , ( "background-color", "red" )
                    ]

                Waiting ->
                    [ ( "color", "gray" )
                    ]

                Skip ->
                    [ ( "color", "gray" )
                    ]

                End ->
                    []
            )
        ]
        [ viewStepContent step.content ]


viewStepContent : String -> Html msg
viewStepContent content =
    if content == "\n" then
        Html.span []
            [ Html.text content
            , Html.br [] []
            ]
    else
        Html.text content
