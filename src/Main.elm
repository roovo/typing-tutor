module Main exposing (..)

import AnimationFrame
import Char
import ExampleExercise
import Exercise exposing (Exercise)
import ExerciseView
import Hop
import Hop.Types as Hop
import Html exposing (Html)
import Html.App
import Navigation
import Routes exposing (Route, urlParser)
import Keyboard exposing (KeyCode)
import Stopwatch exposing (Stopwatch)
import Time exposing (Time)


main =
    Navigation.program urlParser
        { init = init
        , subscriptions = subscriptions
        , update = update
        , urlUpdate = urlUpdate
        , view = view
        }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Keyboard.presses KeyPress
        , Keyboard.downs KeyDown
        , AnimationFrame.diffs Tick
        ]



-- MODEL


type alias Model =
    { exercise : Exercise
    , stopwatch : Stopwatch
    , route : Route
    , address : Hop.Address
    }


init : ( Route, Hop.Address ) -> ( Model, Cmd Msg )
init ( route, address ) =
    ( { exercise = (Debug.log "init.exercise" (Exercise.init ExampleExercise.elm))
      , stopwatch = Stopwatch.init
      , route = route
      , address = address
      }
    , Cmd.none
    )



-- UPDATE


backspaceCode =
    8


type Msg
    = KeyPress KeyCode
    | KeyDown KeyCode
    | Tick Time


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case logWithoutTick msg of
        KeyPress keyCode ->
            if keyCode /= backspaceCode then
                consumeChar keyCode model
            else
                ( model, Cmd.none )

        KeyDown keyCode ->
            if keyCode == backspaceCode then
                consumeChar keyCode model
            else
                ( model, Cmd.none )

        Tick elapsed ->
            ( { model | stopwatch = Stopwatch.tick elapsed model.stopwatch }
            , Cmd.none
            )


consumeChar : Int -> Model -> ( Model, Cmd Msg )
consumeChar keyCode model =
    let
        lappedWatch =
            Stopwatch.lap model.stopwatch
    in
        ( { model
            | exercise =
                Exercise.consume
                    (Char.fromCode keyCode)
                    (Stopwatch.lastLap lappedWatch)
                    model.exercise
            , stopwatch = lappedWatch
          }
        , Cmd.none
        )


logWithoutTick : Msg -> Msg
logWithoutTick msg =
    case msg of
        Tick time ->
            msg

        _ ->
            Debug.log "msg" msg


urlUpdate : ( Route, Hop.Address ) -> Model -> ( Model, Cmd Msg )
urlUpdate ( route, address ) model =
    ( { model
        | route = route
        , address = address
      }
    , Cmd.none
    )



-- VIEW


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
