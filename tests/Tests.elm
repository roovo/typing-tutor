module Tests exposing (..)

import Step exposing (Step, Status(..))
import Expect
import Exercise exposing (Exercise)
import Test exposing (..)
import TestStep
import TestSafeZipper
import TestExercise


all : Test
all =
    describe "Tests"
        [ TestExercise.exercise
        , TestStep.step
        , TestSafeZipper.safeZipper
        ]
