module AllTests exposing (all)

import Test exposing (..)
import DecoderTests
import EventTests
import ExerciseTests
import ExerciseParserTests
import SafeZipperTests
import StepTests
import StopwatchTests


all : Test
all =
    describe "All Tests"
        [ DecoderTests.all
        , EventTests.all
        , ExerciseTests.all
        , ExerciseParserTests.all
        , SafeZipperTests.all
        , StepTests.all
        , StopwatchTests.all
        ]
