port module Main exposing (..)

import AllTests
import Test.Runner.Node exposing (TestProgram, run)
import Json.Encode exposing (Value)


main : TestProgram
main =
    run emit AllTests.all


port emit : ( String, Value ) -> Cmd msg
