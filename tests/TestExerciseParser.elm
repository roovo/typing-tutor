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
        , describe "basic parsers"
            [ test "whitespace" <|
                \() ->
                    parse ExerciseParser.leadingWhitepace "   "
                        |> Expect.equal ( Ok (Step.skip "   "), { input = "", position = 3 } )
            , test "non-whitespace" <|
                \() ->
                    parse ExerciseParser.character "ab"
                        |> Expect.equal ( Ok (Step.init "a"), { input = "b", position = 1 } )
            ]
        , describe "line"
            [ test "parses string without leading whitespace" <|
                \() ->
                    parse ExerciseParser.line "ab c\n"
                        |> Expect.equal
                            ( Ok
                                [ Step.init "a"
                                , Step.init "b"
                                , Step.init " "
                                , Step.init "c"
                                , Step.init "\n"
                                ]
                            , { input = "", position = 5 }
                            )
            , test "parses string with leading whitespace" <|
                \() ->
                    parse ExerciseParser.line "   ab c\n"
                        |> Expect.equal
                            ( Ok
                                [ Step.skip "   "
                                , Step.init "a"
                                , Step.init "b"
                                , Step.init " "
                                , Step.init "c"
                                , Step.init "\n"
                                ]
                            , { input = "", position = 8 }
                            )
            ]
        , describe "lines"
            [ test "parses string with newline" <|
                \() ->
                    parse ExerciseParser.lines " ab\n  cd\n"
                        |> Expect.equal
                            ( Ok
                                [ Step.skip " "
                                , Step.init "a"
                                , Step.init "b"
                                , Step.init "\n"
                                , Step.skip "  "
                                , Step.init "c"
                                , Step.init "d"
                                , Step.init "\n"
                                ]
                            , { input = "", position = 9 }
                            )
            , test "parses string with newline" <|
                \() ->
                    parse ExerciseParser.lines " ab\n  cd\n\n"
                        |> Expect.equal
                            ( Ok
                                [ Step.skip " "
                                , Step.init "a"
                                , Step.init "b"
                                , Step.init "\n"
                                , Step.skip "  "
                                , Step.init "c"
                                , Step.init "d"
                                , Step.init "\n"
                                , Step.init "\n"
                                ]
                            , { input = "", position = 10 }
                            )
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
