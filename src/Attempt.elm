module Attempt exposing (Attempt, init)

import Exercise exposing (Event)
import Model exposing (Model)
import Time exposing (Time)


type alias Attempt =
    { id : Maybe Int
    , completedAt : Time
    , exerciseId : Int
    , accuracy : Float
    , wpm : Float
    , events : List Event
    }


init : Time -> Model -> Attempt
init time model =
    { id = Nothing
    , completedAt = time
    , exerciseId = model.exercise.id
    , accuracy = Exercise.accuracy model.exercise
    , wpm = Exercise.wpm model.exercise
    , events = model.exercise.events
    }
