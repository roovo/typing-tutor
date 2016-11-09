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


backspaceCode : Int
backspaceCode =
    8


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case logWithoutTick msg of
        KeyPress keyCode ->
            consumeChar keyCode model

        KeyDown keyCode ->
            consumeChar keyCode model

        Tick elapsed ->
            ( { model | stopwatch = Stopwatch.tick elapsed model.stopwatch }
            , Cmd.none
            )

        GotTime timeNow ->
            case model.exercise of
                Nothing ->
                    ( model, Cmd.none )

                Just exercise ->
                    ( model
                    , Api.createAttempt model (Attempt.init timeNow exercise) (always NoOp) (always NoOp)
                    )

        GotExercises exercises ->
            ( { model | exercises = exercises }, Cmd.none )

        GotExercise exercise ->
            ( { model | exercise = Just exercise }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


consumeChar : Int -> Model -> ( Model, Cmd Msg )
consumeChar keyCode model =
    let
        lappedWatch =
            Stopwatch.lap model.stopwatch

        newExercise =
            case model.exercise of
                Nothing ->
                    Nothing

                Just exercise ->
                    Just
                        (Exercise.consume
                            (Char.fromCode keyCode)
                            (Stopwatch.lastLap lappedWatch)
                            exercise
                        )

        newModel =
            { model
                | exercise = newExercise
                , stopwatch = lappedWatch
            }
    in
        ( newModel
        , consumeCharCmd newModel
        )


consumeCharCmd : Model -> Cmd Msg
consumeCharCmd model =
    case model.exercise of
        Nothing ->
            Cmd.none

        Just exercise ->
            if Exercise.isComplete exercise then
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
