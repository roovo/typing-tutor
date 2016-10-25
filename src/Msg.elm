module Msg exposing (Msg(..))

import Exercise exposing (Exercise)
import Keyboard exposing (KeyCode)
import Time exposing (Time)


type Msg
    = KeyPress KeyCode
    | KeyDown KeyCode
    | Tick Time
    | GotExercises (List Exercise)
    | GotExercise Exercise
    | NoOp
