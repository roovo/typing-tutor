module Main exposing (..)

import AnimationFrame
import Char
import Exercise exposing (Exercise)
import ExerciseView
import Html exposing (Html)
import Html.App
import Keyboard exposing (KeyCode)
import Stopwatch exposing (Stopwatch)
import Time exposing (Time)


main =
    Html.App.program
        { init = init "Something to type"
        , subscriptions = subscriptions
        , update = update
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
    }


init : String -> ( Model, Cmd Msg )
init source =
    ( { exercise = Exercise.init source
      , stopwatch = Stopwatch.init
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
            consumeChar keyCode model

        KeyDown keyCode ->
            if keyCode == backspaceCode then
                consumeChar backspaceCode model
            else
                ( model, Cmd.none )

        Tick elapsed ->
            ( { model | stopwatch = Stopwatch.tick elapsed model.stopwatch }
            , Cmd.none
            )


consumeChar : Int -> Model -> ( Model, Cmd Msg )
consumeChar keyCode model =
    ( { model
        | exercise = Exercise.consume (Char.fromCode keyCode) model.exercise
        , stopwatch = Stopwatch.start model.stopwatch
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



-- VIEW


view : Model -> Html Msg
view model =
    Html.div
        []
        [ Html.code
            []
            [ ExerciseView.view model.exercise
            ]
        ]
