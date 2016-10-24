module Main exposing (..)

import AnimationFrame
import Char
import Exercise exposing (Exercise)
import Hop
import Hop.Types as Hop
import Model exposing (Model)
import Msg exposing (Msg(..))
import Navigation
import Routes exposing (Route, urlParser)
import Keyboard exposing (KeyCode)
import Stopwatch exposing (Stopwatch)
import View exposing (view)


main =
    Navigation.program urlParser
        { init = Model.init
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



-- UPDATE


backspaceCode =
    8


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
    let
        _ =
            Debug.log "urlUpdate" ( route, address )
    in
        ( { model
            | route = route
            , address = address
          }
        , Cmd.none
        )
