module Main exposing (..)

import Char
import Html exposing (Html)
import Html.App
import Keyboard exposing (KeyCode)
import Script exposing (Script)
import ScriptView


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
    { script : Script
    }


init : String -> ( Model, Cmd Msg )
init toType =
    ( { script = Script.init toType
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = KeyPress KeyCode
    | KeyDown KeyCode


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "msg" msg of
        KeyPress keyCode ->
            ( { model
                | script = Script.tick (Char.fromCode keyCode) model.script
              }
            , Cmd.none )

        KeyDown keyCode ->
            if keyCode == 8 then
                ( { model
                    | script = Script.backspace model.script
                  }
                , Cmd.none )
            else
                ( model, Cmd.none )


-- VIEW


view : Model -> Html Msg
view model =
    Html.div
        []
        [ Html.code
            []
            [ ScriptView.view model.script
            ]
        , Html.hr [] []
        , Html.text <| toString model
        ]
