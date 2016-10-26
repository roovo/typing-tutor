module Attempt exposing (Attempt, init)

import Model exposing (Model)
import Exercise


type alias Attempt =
    { exerciseId : Int
    , accuracy : Float
    , wpm : Float
    }


init : Model -> Attempt
init model =
    { exerciseId = model.exercise.id
    , accuracy = Exercise.accuracy model.exercise
    , wpm = Exercise.wpm model.exercise
    }
