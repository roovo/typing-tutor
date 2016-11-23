module Main exposing (..)

import AnimationFrame
import Exercise
import Model exposing (Model)
import Msg exposing (Msg(..))
import Navigation
import Ports
import Keyboard exposing (KeyCode)
import Update
import UrlUpdate
import View


main : Program Never Model Msg
main =
    Navigation.program UrlChange
        { init = init
        , subscriptions = subscriptions
        , update = Update.update
        , view = View.view
        }


init : Navigation.Location -> ( Model, Cmd Msg )
init location =
    UrlUpdate.urlUpdate location (Model.initialModel location)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.exercise of
        Just exercise ->
            if Exercise.isRunning exercise then
                Sub.batch <|
                    (AnimationFrame.diffs Tick)
                        :: keyboardListeners
            else
                Sub.batch keyboardListeners

        Nothing ->
            Sub.none


keyboardListeners : List (Sub Msg)
keyboardListeners =
    [ Ports.keyDown KeyDown
    , Ports.keyPress KeyPress
    ]
