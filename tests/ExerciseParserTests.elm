module ExerciseParserTests exposing (all)

import Char
import ExerciseParser
import Expect
import Parser
import Step
import Test exposing (..)


all : Test
all =
    describe "ExerciseParser"
        [ lineParser
        , linesParser
        , lineWithContentParser
        , spacesThenTypeablesParser
        , spacesParser
        , toSteps
        , typeablesParser
        , whitespaceLineParser
        ]


lineParser : Test
lineParser =
    describe "lineParser"
        [ test "parses a string with leading whitespace" <|
            \() ->
                "  a b"
                    |> Parser.run ExerciseParser.lineParser
                    |> Expect.equal
                        (Ok
                            [ Step.initSkip "  "
                            , Step.init 'a'
                            , Step.init ' '
                            , Step.init 'b'
                            ]
                        )
        , test "parses a string without leading whitespace" <|
            \() ->
                "a b"
                    |> Parser.run ExerciseParser.lineParser
                    |> Expect.equal
                        (Ok
                            [ Step.init 'a'
                            , Step.init ' '
                            , Step.init 'b'
                            ]
                        )
        , test "parses a string up to a newline" <|
            \() ->
                "a b\n"
                    |> Parser.run ExerciseParser.lineParser
                    |> Expect.equal
                        (Ok
                            [ Step.init 'a'
                            , Step.init ' '
                            , Step.init 'b'
                            ]
                        )
        , test "parses a string which contains only spaces" <|
            \() ->
                "  "
                    |> Parser.run ExerciseParser.lineParser
                    |> Expect.equal (Ok [ Step.initSkip "\u{000D}" ])
        ]


linesParser : Test
linesParser =
    describe "linesParser"
        [ test "parses a single line" <|
            \() ->
                "  a b"
                    |> Parser.run ExerciseParser.linesParser
                    |> Expect.equal
                        (Ok
                            [ Step.initSkip "  "
                            , Step.init 'a'
                            , Step.init ' '
                            , Step.init 'b'
                            ]
                        )
        , test "parses multiple lines" <|
            \() ->
                "  a b\nc d"
                    |> Parser.run ExerciseParser.linesParser
                    |> Expect.equal
                        (Ok
                            [ Step.initSkip "  "
                            , Step.init 'a'
                            , Step.init ' '
                            , Step.init 'b'
                            , Step.init enterChar
                            , Step.init 'c'
                            , Step.init ' '
                            , Step.init 'd'
                            ]
                        )
        , test "parses multiple lines with empty lines" <|
            \() ->
                "  a b\n   \nc d"
                    |> Parser.run ExerciseParser.linesParser
                    |> Expect.equal
                        (Ok
                            [ Step.initSkip "  "
                            , Step.init 'a'
                            , Step.init ' '
                            , Step.init 'b'
                            , Step.init enterChar
                            , Step.initSkip "\u{000D}"
                            , Step.init enterChar
                            , Step.init 'c'
                            , Step.init ' '
                            , Step.init 'd'
                            ]
                        )
        , test "parses multiple lines ending with an empty line" <|
            \() ->
                "  a b\n   \nc d\n  "
                    |> Parser.run ExerciseParser.linesParser
                    |> Expect.equal
                        (Ok
                            [ Step.initSkip "  "
                            , Step.init 'a'
                            , Step.init ' '
                            , Step.init 'b'
                            , Step.init enterChar
                            , Step.initSkip "\u{000D}"
                            , Step.init enterChar
                            , Step.init 'c'
                            , Step.init ' '
                            , Step.init 'd'
                            , Step.init enterChar
                            , Step.initSkip "\u{000D}"
                            ]
                        )
        , test "parses multiple lines ending with a newlines" <|
            \() ->
                "  a b\nc d\n  \n\n\n"
                    |> Parser.run ExerciseParser.linesParser
                    |> Expect.equal
                        (Ok
                            [ Step.initSkip "  "
                            , Step.init 'a'
                            , Step.init ' '
                            , Step.init 'b'
                            , Step.init enterChar
                            , Step.init 'c'
                            , Step.init ' '
                            , Step.init 'd'
                            , Step.init enterChar
                            , Step.initSkip "\u{000D}"
                            ]
                        )
        ]


lineWithContentParser : Test
lineWithContentParser =
    describe "lineWithContentParser"
        [ test "parses a string with leading whitespace" <|
            \() ->
                "  a b"
                    |> Parser.run ExerciseParser.lineWithContentParser
                    |> Expect.equal
                        (Ok
                            [ Step.initSkip "  "
                            , Step.init 'a'
                            , Step.init ' '
                            , Step.init 'b'
                            ]
                        )
        , test "parses a string without leading whitespace" <|
            \() ->
                "a b"
                    |> Parser.run ExerciseParser.lineWithContentParser
                    |> Expect.equal
                        (Ok
                            [ Step.init 'a'
                            , Step.init ' '
                            , Step.init 'b'
                            ]
                        )
        , test "parses a string up to a newline" <|
            \() ->
                "a b\n"
                    |> Parser.run ExerciseParser.lineWithContentParser
                    |> Expect.equal
                        (Ok
                            [ Step.init 'a'
                            , Step.init ' '
                            , Step.init 'b'
                            ]
                        )
        , test "fails to parse an empty string" <|
            \() ->
                ""
                    |> Parser.run ExerciseParser.lineWithContentParser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal
                        (Err
                            [ Parser.Problem "expected spaces, none found"
                            , Parser.Problem "expected typeable characters, none found"
                            ]
                        )
        , test "fails to parse a string which contains only spaces" <|
            \() ->
                "  "
                    |> Parser.run ExerciseParser.lineWithContentParser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Parser.Problem "expected typeable characters, none found" ])
        ]


spacesThenTypeablesParser : Test
spacesThenTypeablesParser =
    describe "spacesThenTypeablesParser"
        [ test "parses a string with leading whitespace" <|
            \() ->
                "  a b"
                    |> Parser.run ExerciseParser.spacesThenTypeablesParser
                    |> Expect.equal
                        (Ok
                            [ Step.initSkip "  "
                            , Step.init 'a'
                            , Step.init ' '
                            , Step.init 'b'
                            ]
                        )
        , test "parses a string up to a newline" <|
            \() ->
                "  a b\n"
                    |> Parser.run ExerciseParser.spacesThenTypeablesParser
                    |> Expect.equal
                        (Ok
                            [ Step.initSkip "  "
                            , Step.init 'a'
                            , Step.init ' '
                            , Step.init 'b'
                            ]
                        )
        , test "fails to parse an empty string" <|
            \() ->
                ""
                    |> Parser.run ExerciseParser.spacesThenTypeablesParser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Parser.Problem "expected spaces, none found" ])
        , test "fails to parse a string without leading spaces" <|
            \() ->
                "a b"
                    |> Parser.run ExerciseParser.spacesThenTypeablesParser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Parser.Problem "expected spaces, none found" ])
        , test "fails to parse a string which contains only spaces" <|
            \() ->
                "  "
                    |> Parser.run ExerciseParser.spacesThenTypeablesParser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Parser.Problem "expected typeable characters, none found" ])
        ]


spacesParser : Test
spacesParser =
    describe "spacesParser"
        [ test "parses a string containing a single space" <|
            \() ->
                " "
                    |> Parser.run ExerciseParser.spacesParser
                    |> Expect.equal (Ok [ Step.initSkip " " ])
        , test "parses a string containing multiple spaces" <|
            \() ->
                "   "
                    |> Parser.run ExerciseParser.spacesParser
                    |> Expect.equal (Ok [ Step.initSkip "   " ])
        , test "parses a string with leading spaces" <|
            \() ->
                "  abcde fgh"
                    |> Parser.run ExerciseParser.spacesParser
                    |> Expect.equal (Ok [ Step.initSkip "  " ])
        , test "parses a string up to a newline" <|
            \() ->
                "  abcde fgh\n"
                    |> Parser.run ExerciseParser.spacesParser
                    |> Expect.equal (Ok [ Step.initSkip "  " ])
        , test "fails to parse an empty string" <|
            \() ->
                ""
                    |> Parser.run ExerciseParser.spacesParser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Parser.Problem "expected spaces, none found" ])
        , test "fails to parse a string containing 'a'" <|
            \() ->
                "a"
                    |> Parser.run ExerciseParser.spacesParser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Parser.Problem "expected spaces, none found" ])
        , test "fails to parse a string containing 'a '" <|
            \() ->
                "a "
                    |> Parser.run ExerciseParser.spacesParser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Parser.Problem "expected spaces, none found" ])
        ]


toSteps : Test
toSteps =
    describe "toSteps"
        [ test "converts an empty string" <|
            \() ->
                ""
                    |> ExerciseParser.toSteps
                    |> Expect.equal [ Step.initEnd ]
        , test "converts a single line" <|
            \() ->
                "ab"
                    |> ExerciseParser.toSteps
                    |> Expect.equal
                        [ Step.init 'a'
                        , Step.init 'b'
                        , Step.initEnd
                        ]
        , test "converts leading spaces to skipped spaces" <|
            \() ->
                "  ab"
                    |> ExerciseParser.toSteps
                    |> Expect.equal
                        [ Step.initSkip "  "
                        , Step.init 'a'
                        , Step.init 'b'
                        , Step.initEnd
                        ]
        , test "ignores trailing newlines" <|
            \() ->
                "ab\n\n"
                    |> ExerciseParser.toSteps
                    |> Expect.equal
                        [ Step.init 'a'
                        , Step.init 'b'
                        , Step.initEnd
                        ]
        , test "converts multiple lines" <|
            \() ->
                "ab\ncd"
                    |> ExerciseParser.toSteps
                    |> Expect.equal
                        [ Step.init 'a'
                        , Step.init 'b'
                        , Step.init enterChar
                        , Step.init 'c'
                        , Step.init 'd'
                        , Step.initEnd
                        ]
        , test "converts multiple lines with a blank line in middle" <|
            \() ->
                "ab\n\ncd"
                    |> ExerciseParser.toSteps
                    |> Expect.equal
                        [ Step.init 'a'
                        , Step.init 'b'
                        , Step.init enterChar
                        , Step.init 'c'
                        , Step.init 'd'
                        , Step.initEnd
                        ]
        , test "ignores trailing whitespace on lines" <|
            \() ->
                "ab  \ncd"
                    |> ExerciseParser.toSteps
                    |> Expect.equal
                        [ Step.init 'a'
                        , Step.init 'b'
                        , Step.init enterChar
                        , Step.init 'c'
                        , Step.init 'd'
                        , Step.initEnd
                        ]
        , test "converts multiple lines with empty lines" <|
            \() ->
                "ab\n   \ncd"
                    |> ExerciseParser.toSteps
                    |> Expect.equal
                        [ Step.init 'a'
                        , Step.init 'b'
                        , Step.init enterChar
                        , Step.initSkip "\u{000D}"
                        , Step.init enterChar
                        , Step.init 'c'
                        , Step.init 'd'
                        , Step.initEnd
                        ]
        , test "converts multiple lines ending with an empty line" <|
            \() ->
                "ab\ncd\n  "
                    |> ExerciseParser.toSteps
                    |> Expect.equal
                        [ Step.init 'a'
                        , Step.init 'b'
                        , Step.init enterChar
                        , Step.init 'c'
                        , Step.init 'd'
                        , Step.initEnd
                        ]
        ]


typeablesParser : Test
typeablesParser =
    describe "typeablesParser"
        [ test "parses a string containing a single typeable character" <|
            \() ->
                "a"
                    |> Parser.run ExerciseParser.typeablesParser
                    |> Expect.equal (Ok [ Step.init 'a' ])
        , test "parses a string containing multiple typeable characters" <|
            \() ->
                "a b"
                    |> Parser.run ExerciseParser.typeablesParser
                    |> Expect.equal
                        (Ok
                            [ Step.init 'a'
                            , Step.init ' '
                            , Step.init 'b'
                            ]
                        )
        , test "ignores trailing spaces" <|
            \() ->
                "a  "
                    |> Parser.run ExerciseParser.typeablesParser
                    |> Expect.equal (Ok [ Step.init 'a' ])
        , test "parses up to a newline" <|
            \() ->
                "a\n"
                    |> Parser.run ExerciseParser.typeablesParser
                    |> Expect.equal (Ok [ Step.init 'a' ])
        , test "fails to parse a string containing a single space" <|
            \() ->
                " "
                    |> Parser.run ExerciseParser.typeablesParser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Parser.Problem "expected typeable characters, none found" ])
        , test "fails to parse an empty string" <|
            \() ->
                ""
                    |> Parser.run ExerciseParser.typeablesParser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Parser.Problem "expected typeable characters, none found" ])
        ]


whitespaceLineParser : Test
whitespaceLineParser =
    describe "whitespaceLineParser"
        [ test "parses a string containing a single space" <|
            \() ->
                " "
                    |> Parser.run ExerciseParser.whitespaceLineParser
                    |> Expect.equal (Ok [ Step.initSkip "\u{000D}" ])
        , test "parses a string containing multiple spaces" <|
            \() ->
                "    "
                    |> Parser.run ExerciseParser.whitespaceLineParser
                    |> Expect.equal (Ok [ Step.initSkip "\u{000D}" ])
        , test "parses up to a newline" <|
            \() ->
                "    \n"
                    |> Parser.run ExerciseParser.whitespaceLineParser
                    |> Expect.equal (Ok [ Step.initSkip "\u{000D}" ])
        , test "parses a line with leading spaces" <|
            \() ->
                "  a"
                    |> Parser.run ExerciseParser.whitespaceLineParser
                    |> Expect.equal (Ok [ Step.initSkip "\u{000D}" ])
        , test "fails to parse an empty string" <|
            \() ->
                ""
                    |> Parser.run ExerciseParser.whitespaceLineParser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Parser.Problem "expected whitespace line, not found" ])
        , test "fails to parse a line with non-whitespace character" <|
            \() ->
                "a"
                    |> Parser.run ExerciseParser.whitespaceLineParser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Parser.Problem "expected whitespace line, not found" ])
        ]



-- stepsParser : Test
-- stepsParser =
--     describe "stepsParser"
--         [ test "parses an empty string" <|
--             \() ->
--                 ""
--                     |> Parser.run ExerciseParser.stepsParser
--                     |> Result.withDefault [ Step.init 'x' ]
--                     |> Expect.equal []
--         , test "parses a line containing some characters" <|
--             \() ->
--                 "a$b"
--                     |> Parser.run ExerciseParser.stepsParser
--                     |> Result.withDefault [ Step.init 'x' ]
--                     |> Expect.equal
--                         [ Step.init 'a'
--                         , Step.init '$'
--                         , Step.init 'b'
--                         ]
--
--         -- , test "treats leading whitespace as a Skip" <|
--         --     \() ->
--         --         "  ab"
--         --             |> Parser.run ExerciseParser.stepsParser
--         --             |> Result.withDefault [ Step.init 'x' ]
--         --             |> Expect.equal
--         --                 [ Step.initSkip "  "
--         --                 , Step.init 'a'
--         --                 , Step.init 'b'
--         --                 ]
--         -- [ test "returns just an end Step for an empty string" <|
--         --     \() ->
--         --         ExerciseParser.toSteps ""
--         --             |> Expect.equal
--         --                 [ Step.initEnd
--         --                 ]
--         -- , test "returns steps for an newline terminated string" <|
--         --     \() ->
--         --         ExerciseParser.toSteps "ab\n"
--         --             |> Expect.equal
--         --                 [ Step.init 'a'
--         --                 , Step.init 'b'
--         --                 , Step.initEnd
--         --                 ]
--         -- , test "returns steps for a double newline terminated string" <|
--         --     \() ->
--         --         ExerciseParser.toSteps "ab\n\n"
--         --             |> Expect.equal
--         --                 [ Step.init 'a'
--         --                 , Step.init 'b'
--         --                 , Step.initEnd
--         --                 ]
--         -- , test "returns steps for a crlf terminated string" <|
--         --     \() ->
--         --         ExerciseParser.toSteps "ab\u{000D}\n"
--         --             |> Expect.equal
--         --                 [ Step.init 'a'
--         --                 , Step.init 'b'
--         --                 , Step.initEnd
--         --                 ]
--         -- , test "returns steps for a crlf terminated string contatining a crlf" <|
--         --     \() ->
--         --         ExerciseParser.toSteps "ab\u{000D}\ncd\u{000D}\n"
--         --             |> Expect.equal
--         --                 [ Step.init 'a'
--         --                 , Step.init 'b'
--         --                 , Step.init enterChar
--         --                 , Step.init 'c'
--         --                 , Step.init 'd'
--         --                 , Step.initEnd
--         --                 ]
--         -- , test "removes trailing whitespace from lines" <|
--         --     \() ->
--         --         ExerciseParser.toSteps "a \nb \nc"
--         --             |> Expect.equal
--         --                 [ Step.init 'a'
--         --                 , Step.init enterChar
--         --                 , Step.init 'b'
--         --                 , Step.init enterChar
--         --                 , Step.init 'c'
--         --                 , Step.initEnd
--         --                 ]
--         -- , test "returns skipped whitespace for leading whitespace" <|
--         --     \() ->
--         --         ExerciseParser.toSteps "a\n  b\n"
--         --             |> Expect.equal
--         --                 [ Step.init 'a'
--         --                 , Step.init enterChar
--         --                 , Step.initSkip "  "
--         --                 , Step.init 'b'
--         --                 , Step.initEnd
--         --                 ]
--         -- , test "skips the whole line if it only contains skipped characters" <|
--         --     \() ->
--         --         ExerciseParser.toSteps "a\n  \n b\n"
--         --             |> Expect.equal
--         --                 [ Step.init 'a'
--         --                 , Step.init enterChar
--         --                 , Step.initSkip "  "
--         --                 , Step.initSkip "\u{000D}"
--         --                 , Step.initSkip " "
--         --                 , Step.init 'b'
--         --                 , Step.initEnd
--         --                 ]
--         -- , test "returns steps for an unterminated string" <|
--         --     \() ->
--         --         ExerciseParser.toSteps "ab"
--         --             |> Expect.equal
--         --                 [ Step.init 'a'
--         --                 , Step.init 'b'
--         --                 , Step.initEnd
--         --                 ]
--         ]
--


enterChar : Char
enterChar =
    Char.fromCode 13
