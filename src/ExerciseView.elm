module ExerciseView exposing (view)

import Html exposing (Html)
import Html.Attributes
import Exercise exposing (Exercise)
import Step exposing (Step, Status(..))
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


percentage : Float -> String
percentage float =
    float
        |> (*) 100
        |> truncate
        |> toFloat
        |> (flip (/) 100.0)
        |> toString
        |> (flip (++) "%")


fmod : Float -> Int -> Float
fmod f n =
    let
        integer =
            floor f
    in
        toFloat (integer % n) + f - toFloat integer


addLeadingZero : Int -> String
addLeadingZero num =
    if num < 10 then
        "0" ++ (toString num)
    else
        toString num


timer : Time -> String
timer time =
    let
        secs =
            round <| (time / 1000) `fmod` 60

        mins =
            round <| time / 60000
    in
        addLeadingZero mins ++ ":" ++ addLeadingZero secs


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
                    "Time taken: "
                        ++ (timer <| exercise.timeTaken)
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
