module Tests exposing (..)

import Step exposing (Step, Status(..))
import Expect
import Exercise exposing (Exercise)
import Test exposing (..)
import TestDecoders
import TestExercise
import TestExerciseParser
import TestSafeZipper
import TestStep
import TestStopwatch


all : Test
all =
    describe "All Tests"
        [ TestExercise.tests
        , TestSafeZipper.tests
        , TestStep.tests
        , TestStopwatch.tests
        , TestExerciseParser.tests
        , TestDecoders.tests
        ]
