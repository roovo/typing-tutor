module Main exposing (..)

import AnimationFrame
import Char
import Exercise exposing (Exercise)
import ExerciseView
import Html exposing (Html)
import Html.App
import Keyboard exposing (KeyCode)
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
    }


init : String -> ( Model, Cmd Msg )
init source =
    ( { exercise = Exercise.init source
      }
    , Cmd.none
    )



-- UPDATE


backspaceChar =
    (Char.fromCode 8)


type Msg
    = KeyPress KeyCode
    | KeyDown KeyCode
    | Tick Time


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case logWithoutTick msg of
        KeyPress keyCode ->
            ( { model
                | exercise = Exercise.consume (Char.fromCode keyCode) model.exercise
              }
            , Cmd.none
            )

        KeyDown keyCode ->
            if keyCode == 8 then
                ( { model
                    | exercise = Exercise.consume backspaceChar model.exercise
                  }
                , Cmd.none
                )
            else
                ( model, Cmd.none )

        Tick elapsed ->
            ( model, Cmd.none )


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
