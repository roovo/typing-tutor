module ExerciseView exposing (view)

import Html exposing (Html)
import Html.Attributes
import Exercise exposing (Exercise)
import Step exposing (Step, Status(..))


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


percentage : Float -> String
percentage float =
    float
        |> (*) 100
        |> truncate
        |> toFloat
        |> (flip (/) 100.0)
        |> toString
        |> (flip (++) "%")


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
                ]
            ]
        ]
    else
        []


viewStep : Step -> Html msg
viewStep chunk =
    Html.span
        [ Html.Attributes.style
            (case chunk.status of
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

                End ->
                    []
            )
        ]
        [ Html.text chunk.content ]
