module ExerciseParserTests exposing (all)

import Combine as P
import Combine.Char as Char
import ExerciseParser
import Expect
import Step
import Test exposing (..)


all : Test
all =
    describe "ExerciseParser"
        [ experimentationTests
        , toStepsTests
        ]


experimentationTests : Test
experimentationTests =
    describe "experimentation"
        [ test "eol - \n" <|
            \() ->
                P.parse (P.manyTill (P.regex ".") (Char.eol)) "abc\nde"
                    |> Expect.equal ( Ok [ "a", "b", "c" ], { input = "de", position = 4 } )
        , test "eol - \x0D \n" <|
            \() ->
                P.parse (P.manyTill (P.regex ".") (Char.eol)) "abc\x0D\nde"
                    |> Expect.equal ( Ok [ "a", "b", "c" ], { input = "de", position = 5 } )
        , test "regex . doesn't match eol" <|
            \() ->
                P.parse (P.many (P.regex ".")) "abc\nde"
                    |> Expect.equal ( Ok [ "a", "b", "c" ], { input = "\nde", position = 3 } )
        ]


toStepsTests : Test
toStepsTests =
    describe "toSteps"
        [ test "returns just an end Step for an empty string" <|
            \() ->
                ExerciseParser.toSteps ""
                    |> Expect.equal
                        [ Step.initEnd
                        ]
        , test "returns steps for an newline terminated string" <|
            \() ->
                ExerciseParser.toSteps "ab\n"
                    |> Expect.equal
                        [ Step.init "a"
                        , Step.init "b"
                        , Step.initEnd
                        ]
        , test "returns steps for a double newline terminated string" <|
            \() ->
                ExerciseParser.toSteps "ab\n\n"
                    |> Expect.equal
                        [ Step.init "a"
                        , Step.init "b"
                        , Step.initEnd
                        ]
        , test "returns steps for an crlf terminated string" <|
            \() ->
                ExerciseParser.toSteps "ab\x0D\n"
                    |> Expect.equal
                        [ Step.init "a"
                        , Step.init "b"
                        , Step.initEnd
                        ]
        , test "returns steps for an crlf terminated string" <|
            \() ->
                ExerciseParser.toSteps "ab\x0D\ncd\x0D\n"
                    |> Expect.equal
                        [ Step.init "a"
                        , Step.init "b"
                        , Step.init "\x0D"
                        , Step.init "c"
                        , Step.init "d"
                        , Step.initEnd
                        ]
        , test "removes trailing whitespace from lines" <|
            \() ->
                ExerciseParser.toSteps "a \nb \nc"
                    |> Expect.equal
                        [ Step.init "a"
                        , Step.init "\x0D"
                        , Step.init "b"
                        , Step.init "\x0D"
                        , Step.init "c"
                        , Step.initEnd
                        ]
        , test "returns skipped whitespace for leading whitespace" <|
            \() ->
                ExerciseParser.toSteps "a\n  b\n"
                    |> Expect.equal
                        [ Step.init "a"
                        , Step.init "\x0D"
                        , Step.initSkip "  "
                        , Step.init "b"
                        , Step.initEnd
                        ]
        , test "skips the whole line if it only contains skipped characters" <|
            \() ->
                ExerciseParser.toSteps "a\n  \n b\n"
                    |> Expect.equal
                        [ Step.init "a"
                        , Step.init "\x0D"
                        , Step.initSkip "  "
                        , Step.initSkip "\x0D"
                        , Step.initSkip " "
                        , Step.init "b"
                        , Step.initEnd
                        ]
        , test "returns steps for an unterminated string" <|
            \() ->
                ExerciseParser.toSteps "ab"
                    |> Expect.equal
                        [ Step.init "a"
                        , Step.init "b"
                        , Step.initEnd
                        ]
        ]
