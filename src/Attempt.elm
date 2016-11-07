module Attempt exposing (Attempt, init)

import Event exposing (Event)
import Exercise exposing (Exercise)
import Model
import Time exposing (Time)


type alias Attempt =
    { id : Maybe Int
    , completedAt : Time
    , exerciseId : Int
    , accuracy : Float
    , wpm : Float
    , events : List Event
    }


init : Time -> Exercise -> Attempt
init time exercise =
    { id = Nothing
    , completedAt = time
    , exerciseId = exercise.id
    , accuracy = Exercise.accuracy exercise
    , wpm = Event.wpm exercise.events
    , events = exercise.events
    }
