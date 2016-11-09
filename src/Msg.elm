module Msg exposing (Msg(..))

import Attempt exposing (Attempt)
import Exercise exposing (Exercise)
import Keyboard exposing (KeyCode)
import Time exposing (Time)


type Msg
    = KeyPress KeyCode
    | KeyDown KeyCode
    | Tick Time
    | GotTime Time
    | GotExercises (List Exercise)
    | GotExercise Exercise
    | GotAttempts (List Attempt)
    | NoOp
