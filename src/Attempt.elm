module Attempt exposing (Attempt, init)

import Event exposing (Event)
import Exercise exposing (Exercise)
import Time exposing (Posix)


type alias Attempt =
    { id : Maybe Int
    , completedAt : Posix
    , exerciseId : Int
    , accuracy : Float
    , wpm : Float
    , events : List Event
    }


init : Posix -> Exercise -> Attempt
init time exercise =
    { id = Nothing
    , completedAt = time
    , exerciseId = exercise.id
    , accuracy = Exercise.accuracy exercise
    , wpm = Exercise.wpm exercise
    , events = exercise.events
    }
