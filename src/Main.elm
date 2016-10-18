module Main exposing (..)

import Char
import Exercise exposing (Exercise)
import Html exposing (Html)
import Html.App
import Keyboard exposing (KeyCode)
import ExerciseView


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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "msg" msg of
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



-- VIEW


view : Model -> Html Msg
view model =
    Html.div
        []
        [ Html.code
            []
            [ ExerciseView.view model.exercise
            ]
        , Html.hr [] []
        , Html.text <| toString model
        ]
