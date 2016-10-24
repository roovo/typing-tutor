module Msg exposing (Msg(..))

import Keyboard exposing (KeyCode)
import Time exposing (Time)


type Msg
    = KeyPress KeyCode
    | KeyDown KeyCode
    | Tick Time
