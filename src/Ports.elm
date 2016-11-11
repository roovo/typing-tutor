port module Ports exposing (keyDown, keyPress)

import Keyboard exposing (KeyCode)


port keyDown : (KeyCode -> msg) -> Sub msg


port keyPress : (KeyCode -> msg) -> Sub msg
