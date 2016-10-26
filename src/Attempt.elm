module Attempt exposing (Attempt, init)

import Model exposing (Model)
import Exercise


type alias Attempt =
    { id : Maybe Int
    , exerciseId : Int
    , accuracy : Float
    , wpm : Float
    }


init : Model -> Attempt
init model =
    { id = Nothing
    , exerciseId = model.exercise.id
    , accuracy = Exercise.accuracy model.exercise
    , wpm = Exercise.wpm model.exercise
    }
