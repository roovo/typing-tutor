port module Main exposing (..)

import AllTests
import Test.Runner.Node exposing (run)
import Json.Encode exposing (Value)


main : Program Value
main =
    run emit AllTests.all


port emit : ( String, Value ) -> Cmd msg
