module TestExerciseParser exposing (..)

import Combine exposing (many, parse, regex)
import ExerciseParser
import Expect
import Step
import Test exposing (..)


exerciseParser : Test
exerciseParser =
    describe "ExerciseParser"
        [ describe "testing"
            [ test "parses whitespace" <|
                \() ->
                    parse ExerciseParser.leadingWhitepace "   "
                        |> Expect.equal ( Ok (Step.skip "   "), { input = "", position = 3 } )
            ]
        ]
