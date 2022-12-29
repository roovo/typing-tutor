module Update exposing (update)

import Api
import Attempt
import Char
import Exercise
import Model exposing (Model)
import Msg exposing (Msg(..))
import Ports
import Stopwatch
import Task
import Time exposing (Posix)


backspaceCode : Int
backspaceCode =
    8


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
                Task.perform GotTime Time.now

            else
                Ports.scrollIfNearEdge 1
