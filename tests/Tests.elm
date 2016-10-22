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
    describe "Tests"
        [ TestExercise.exercise
        , TestStep.step
        , TestSafeZipper.safeZipper
        , TestStopwatch.stopwatch
        , TestExerciseParser.exerciseParser
        ]
