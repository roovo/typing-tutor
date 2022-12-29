module Msg exposing (Msg(..))

import Attempt exposing (Attempt)
import Browser
import Url exposing (Url)
import Exercise exposing (Exercise)
import Http
import Time exposing (Posix)


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | CreatedAttempt (Result Http.Error Attempt)
    | GotAttempts (Result Http.Error (List Attempt))
    | GotExercise (Result Http.Error Exercise)
    | GotExercises (Result Http.Error (List Exercise))
    | GotTime Posix
    -- | KeyDown KeyCode
    -- | KeyPress KeyCode
    | Tick Posix
