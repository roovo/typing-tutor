module Page.Exercise exposing
    ( Model
    , Msg
    , init
    , toSession
    , update
    , view
    )

import Api
import Api.Endpoint as Endpoint
import Event
import Exercise exposing (Exercise, Printable, Style(..))
import Html exposing (Html)
import Html.Attributes
import Http
import Json.Decode as JD
import Json.Encode as JE
import Page.Error
import Route
import Session exposing (Session)
import Stopwatch exposing (Stopwatch)



-- MODEL


type alias Model =
    { session : Session
    , exercise : Status Exercise
    }


type Status a
    = Loading
    | LoadingSlowly
    | Loaded a
    | Failed


init : Session -> Int -> ( Model, Cmd Msg )
init session id =
    ( { session = session
      , exercise = Loading
      }
    , fetchExercise session id
    )


toSession : Model -> Session
toSession =
    .session



-- UPDATE


type Msg
    = CompletedExerciseFetch (Result Http.Error Exercise)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.exercise ) of
        ( CompletedExerciseFetch (Ok exercise), _ ) ->
            ( { model | exercise = Loaded exercise }, Cmd.none )

        ( CompletedExerciseFetch (Err _), _ ) ->
            ( { model | exercise = Failed }, Cmd.none )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    let
        pageTitle =
            "Exercise"

        stopwatch =
            Session.stopwatch <| toSession model
    in
    case model.exercise of
        Loaded exercise ->
            { title = pageTitle
            , content = content exercise stopwatch
            }

        Loading ->
            { title = pageTitle
            , content = Html.text ""
            }

        LoadingSlowly ->
            { title = pageTitle
            , content = Html.text "Loading..."
            }

        Failed ->
            Page.Error.view "exercise"


content : Exercise -> Stopwatch -> Html Msg
content exercise stopwatch =
    Html.div []
        [ Html.h2 [] [ Html.text "Exercise" ]
        , Html.div []
            [ exerciseView exercise
            , Html.hr [] []
            , stopwatchView exercise stopwatch
            ]
        ]


exerciseView : Exercise -> Html msg
exerciseView exercise =
    Html.div []
        (List.append
            (viewSteps exercise)
            (viewResults exercise)
        )


stopwatchView : Exercise -> Stopwatch -> Html Msg
stopwatchView exercise stopwatch =
    case Exercise.isComplete exercise of
        True ->
            Html.text ""

        False ->
            Html.p []
                [ Html.text <|
                    Stopwatch.view <|
                        stopwatch.time
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
        ((case printable.style of
            Completed ->
                [ Html.Attributes.style "color" "black"
                ]

            Current ->
                [ Html.Attributes.style "color" "black"
                , Html.Attributes.style "background-color" "orange"
                ]

            Error ->
                [ Html.Attributes.style "color" "gray"
                , Html.Attributes.style "background-color" "red"
                ]

            Waiting ->
                [ Html.Attributes.style "color" "gray"
                ]
         )
            ++ (if printable.style == Current then
                    [ Html.Attributes.id "current" ]

                else
                    []
               )
        )
        [ viewPrintableContent printable.content ]


viewPrintableContent : String -> Html msg
viewPrintableContent c =
    if c == "\u{000D}" then
        Html.span []
            [ Html.text " "
            , Html.br [] []
            ]

    else
        Html.text c


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

                -- ++ Stopwatch.view (Event.timeTaken exercise.events)
                ]
            ]
        ]

    else
        []



-- PRIVATE


fetchExercise : Session -> Int -> Cmd Msg
fetchExercise session id =
    Exercise.decoder
        |> Http.expectJson CompletedExerciseFetch
        |> Api.getOne (Endpoint.exercise (Session.apiRoot session) id)


percentage : Float -> String
percentage float =
    float
        |> (*) 100
        |> truncate
        |> toFloat
        |> (\n -> n / 100.0)
        |> String.fromFloat
        |> (\n -> n ++ "%")
