module Main exposing (..)

import AnimationFrame
import Hop.Types as Hop
import Model exposing (Model)
import Msg exposing (Msg(..))
import Navigation
import Ports
import Route exposing (Route(..), urlParser)
import Keyboard exposing (KeyCode)
import Update
import UrlUpdate
import View


main : Program Never
main =
    Navigation.program urlParser
        { init = init
        , subscriptions = subscriptions
        , update = Update.update
        , urlUpdate = UrlUpdate.urlUpdate
        , view = View.view
        }


init : ( Route, Hop.Address ) -> ( Model, Cmd Msg )
init ( route, address ) =
    UrlUpdate.urlUpdate
        ( route, address )
    <|
        Model.initialModel <|
            ( route, address )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ AnimationFrame.diffs Tick
        , Ports.keyDown KeyDown
        , Ports.keyPress KeyPress
        ]
