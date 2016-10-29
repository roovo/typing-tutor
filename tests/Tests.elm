module Tests exposing (..)

import Step exposing (Step, Status(..))
import Expect
import Exercise exposing (Exercise)
import Test exposing (..)
import TestExercise
import TestExerciseParser
import TestSafeZipper
import TestStep
import TestStopwatch


all : Test
all =
    describe "All Tests"
        [ TestExercise.tests
        , TestStep.tests
        , TestSafeZipper.tests
        , TestStopwatch.tests
        , TestExerciseParser.tests
        ]
