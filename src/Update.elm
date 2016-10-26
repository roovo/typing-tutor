module Update exposing (update)

import Api
import Attempt
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
        , cmdForNewChar newModel
        )


cmdForNewChar : Model -> Cmd Msg
cmdForNewChar model =
    if Exercise.isComplete model.exercise then
        Api.createAttempt model (Attempt.init model) (always NoOp) (always NoOp)
    else
        Cmd.none


logWithoutTick : Msg -> Msg
logWithoutTick msg =
    case msg of
        Tick time ->
            msg

        _ ->
            Debug.log "msg" msg
