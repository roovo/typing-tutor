module TestExerciseParser exposing (..)

import Combine exposing (many, parse, regex)
import ExerciseParser
import Expect
import Step
import Test exposing (..)


exerciseParser : Test
exerciseParser =
    describe "ExerciseParser"
        [ describe "basic parsers"
            [ test "whitespace" <|
                \() ->
                    parse ExerciseParser.leadingWhitepace "   "
                        |> Expect.equal ( Ok (Step.skip "   "), { input = "", position = 3 } )
            , test "non-whitespace" <|
                \() ->
                    parse ExerciseParser.character "ab"
                        |> Expect.equal ( Ok (Step.init "a"), { input = "b", position = 1 } )
            ]
        , describe "toSteps"
            [ test "parses string without leading whitespace" <|
                \() ->
                    parse ExerciseParser.toSteps "ab c"
                        |> Expect.equal
                            ( Ok
                                [ Step.init "a"
                                , Step.init "b"
                                , Step.init " "
                                , Step.init "c"
                                ]
                            , { input = "", position = 4 }
                            )
            , test "parses string with leading whitespace" <|
                \() ->
                    parse ExerciseParser.toSteps "   ab c"
                        |> Expect.equal
                            ( Ok
                                [ Step.skip "   "
                                , Step.init "a"
                                , Step.init "b"
                                , Step.init " "
                                , Step.init "c"
                                ]
                            , { input = "", position = 7 }
                            )
            ]
        ]
