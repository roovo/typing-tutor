module TestExerciseParser exposing (..)

import Combine exposing (many, manyTill, parse, regex)
import Combine.Char as Char
import ExerciseParser
import Expect
import Step
import Test exposing (..)


exerciseParser : Test
exerciseParser =
    describe "ExerciseParser"
        [ describe "experimentation"
            [ test "eol - \n" <|
                \() ->
                    parse (manyTill (regex ".") (Char.eol)) "abc\nde"
                        |> Expect.equal ( Ok [ "a", "b", "c" ], { input = "de", position = 4 } )
            , test "eol - \x0D \n" <|
                \() ->
                    parse (manyTill (regex ".") (Char.eol)) "abc\x0D\nde"
                        |> Expect.equal ( Ok [ "a", "b", "c" ], { input = "de", position = 5 } )
            ]
        , describe "toSteps"
            [ test "returns no steps for an empty string" <|
                \() ->
                    ExerciseParser.toSteps ""
                        |> Expect.equal
                            [ Step.init "\n"
                            ]
            , test "returns steps for an newline terminated string" <|
                \() ->
                    ExerciseParser.toSteps "ab\n"
                        |> Expect.equal
                            [ Step.init "a"
                            , Step.init "b"
                            , Step.init "\n"
                            ]
            , test "returns steps for an crlf terminated string" <|
                \() ->
                    ExerciseParser.toSteps "ab\x0D\n"
                        |> Expect.equal
                            [ Step.init "a"
                            , Step.init "b"
                            , Step.init "\n"
                            ]
            , test "returns steps for an unterminated string" <|
                \() ->
                    ExerciseParser.toSteps "ab"
                        |> Expect.equal
                            [ Step.init "a"
                            , Step.init "b"
                            , Step.init "\n"
                            ]
            ]
        ]
