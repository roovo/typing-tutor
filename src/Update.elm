module Update exposing (update)

import Char
import Exercise
import Msg exposing (Msg(..))
import Model exposing (Model)
import Stopwatch


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

        GotExercises exercises ->
            ( model, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


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
