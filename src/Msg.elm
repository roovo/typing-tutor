module Msg exposing (Msg(..))

import Attempt exposing (Attempt)
import Exercise exposing (Exercise)
import Http
import Keyboard exposing (KeyCode)
import Navigation
import Time exposing (Time)


type Msg
    = KeyPress KeyCode
    | KeyDown KeyCode
    | Tick Time
    | GotTime Time
    | GotExercises (Result Http.Error (List Exercise))
    | GotExercise (Result Http.Error Exercise)
    | GotAttempts (Result Http.Error (List Attempt))
    | CreatedAttempt (Result Http.Error Attempt)
    | UrlChange Navigation.Location
