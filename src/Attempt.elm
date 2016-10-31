module Attempt exposing (Attempt, init)

import Event exposing (Event)
import Exercise
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
    , accuracy = Event.accuracy model.exercise.events
    , wpm = Event.wpm model.exercise.events
    , events = model.exercise.events
    }
