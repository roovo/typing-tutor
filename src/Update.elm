module Update exposing (update)

import Api
import Attempt
import Char
import Exercise
import Msg exposing (Msg(..))
import Model exposing (Model)
import Stopwatch
import Task
import Time exposing (Time)


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

        GotTime timeNow ->
            ( model
            , Api.createAttempt model (Attempt.init timeNow model.exercise) (always NoOp) (always NoOp)
            )

        GotExercises exercises ->
            ( { model | exercises = exercises }, Cmd.none )

        GotExercise exercise ->
            ( { model | exercise = exercise }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


consumeChar : Int -> Model -> ( Model, Cmd Msg )
consumeChar keyCode model =
    let
        lappedWatch =
            Stopwatch.lap model.stopwatch

        newModel =
            { model
                | exercise =
                    Exercise.consume
                        (Char.fromCode keyCode)
                        (Stopwatch.lastLap lappedWatch)
                        model.exercise
                , stopwatch = lappedWatch
            }
    in
        ( newModel
        , consumeCharCmd newModel
        )


consumeCharCmd : Model -> Cmd Msg
consumeCharCmd model =
    if Exercise.isComplete model.exercise then
        Task.perform (always NoOp) (GotTime) Time.now
    else
        Cmd.none


logWithoutTick : Msg -> Msg
logWithoutTick msg =
    case msg of
        Tick time ->
            msg

        _ ->
            Debug.log "msg" msg
