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
        [ emptyLineParser
        , lineParser
        , linesParser
        , lineWithContentParser
        , spacesThenTypeablesParser
        , spacesParser
        , toSteps
        , typeablesParser
        , whitespaceLineParser
        ]


emptyLineParser : Test
emptyLineParser =
    describe "emptyLineParser"
        [ test "parses a string containing a single newline" <|
            \() ->
                "\n"
                    |> Parser.run ExerciseParser.emptyLineParser
                    |> Expect.equal (Ok [ Step.initSkip enterString ])
        , test "parses a string containing multiple newlines" <|
            \() ->
                "\n\n"
                    |> Parser.run ExerciseParser.emptyLineParser
                    |> Expect.equal (Ok [ Step.initSkip enterString ])
        , test "fails to parse an empty string" <|
            \() ->
                ""
                    |> Parser.run ExerciseParser.emptyLineParser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Parser.Expecting "\n" ])
        , test "fails to parse a non empty string" <|
            \() ->
                "a"
                    |> Parser.run ExerciseParser.emptyLineParser
                    |> Result.mapError (List.map .problem)
                    |> Expect.equal (Err [ Parser.Expecting "\n" ])
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
                            , Step.init enterChar
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
                            , Step.init enterChar
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
                            , Step.init enterChar
                            ]
                        )
        , test "parses a string which contains only spaces" <|
            \() ->
                "  "
                    |> Parser.run ExerciseParser.lineParser
                    |> Expect.equal
                        (Ok
                            [ Step.initSkip "  "
                            , Step.initSkip enterString
                            ]
                        )
        , test "parses a string which contains only spaces ending in a newline" <|
            \() ->
                "  \n"
                    |> Parser.run ExerciseParser.lineParser
                    |> Expect.equal
                        (Ok
                            [ Step.initSkip "  "
                            , Step.initSkip enterString
                            ]
                        )
        , test "parses a string which contains only spaces ending in multiple newlines" <|
            \() ->
                "  \n\n\n"
                    |> Parser.run ExerciseParser.lineParser
                    |> Expect.equal
                        (Ok
                            [ Step.initSkip "  "
                            , Step.initSkip enterString
                            ]
                        )
        , test "parses a string which contains only a newline" <|
            \() ->
                "\n"
                    |> Parser.run ExerciseParser.lineParser
                    |> Expect.equal (Ok [ Step.initSkip enterString ])
        , test "parses a string which contains multiple newlines" <|
            \() ->
                "\n\n\n"
                    |> Parser.run ExerciseParser.lineParser
                    |> Expect.equal (Ok [ Step.initSkip enterString ])
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
                            , Step.init enterChar
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
                            , Step.init enterChar
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
                            , Step.initSkip "   "
                            , Step.initSkip enterString
                            , Step.init 'c'
                            , Step.init ' '
                            , Step.init 'd'
                            , Step.init enterChar
                            ]
                        )
        , test "parses multiple lines ending with an empty line on the end" <|
            \() ->
                "ab\n   \ncd\n  "
                    |> Parser.run ExerciseParser.linesParser
                    |> Expect.equal
                        (Ok
                            [ Step.init 'a'
                            , Step.init 'b'
                            , Step.init enterChar
                            , Step.initSkip "   "
                            , Step.initSkip enterString
                            , Step.init 'c'
                            , Step.init 'd'
                            , Step.init enterChar
                            , Step.initSkip "  "
                            , Step.initSkip enterString
                            ]
                        )
        , test "parses blank lines" <|
            \() ->
                "a\n\nc"
                    |> Parser.run ExerciseParser.linesParser
                    |> Expect.equal
                        (Ok
                            [ Step.init 'a'
                            , Step.init enterChar
                            , Step.initSkip enterString
                            , Step.init 'c'
                            , Step.init enterChar
                            ]
                        )
        , test "parses multiple lines ending with newlines" <|
            \() ->
                "ab\ncd\n \n\n\n"
                    |> Parser.run ExerciseParser.linesParser
                    |> Expect.equal
                        (Ok
                            [ Step.init 'a'
                            , Step.init 'b'
                            , Step.init enterChar
                            , Step.init 'c'
                            , Step.init 'd'
                            , Step.init enterChar
                            , Step.initSkip " "
                            , Step.initSkip enterString
                            , Step.initSkip enterString
                            , Step.initSkip enterString
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
                            , Step.init enterChar
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
                            , Step.init enterChar
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
                            , Step.init enterChar
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
                        , Step.initSkip enterString
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
                        , Step.initSkip "   "
                        , Step.initSkip enterString
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
                    |> Expect.equal
                        (Ok
                            [ Step.initSkip " "
                            , Step.initSkip enterString
                            ]
                        )
        , test "parses a string containing multiple spaces" <|
            \() ->
                "    "
                    |> Parser.run ExerciseParser.whitespaceLineParser
                    |> Expect.equal
                        (Ok
                            [ Step.initSkip "    "
                            , Step.initSkip enterString
                            ]
                        )
        , test "parses up to a newline" <|
            \() ->
                "    \n"
                    |> Parser.run ExerciseParser.whitespaceLineParser
                    |> Expect.equal
                        (Ok
                            [ Step.initSkip "    "
                            , Step.initSkip enterString
                            ]
                        )
        , test "parses a line with leading spaces - TODO really should write a version where this fails" <|
            \() ->
                "  a"
                    |> Parser.run ExerciseParser.whitespaceLineParser
                    |> Expect.equal
                        (Ok
                            [ Step.initSkip "  "
                            , Step.initSkip enterString
                            ]
                        )
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


enterChar : Char
enterChar =
    Char.fromCode 13


enterString : String
enterString =
    "\u{000D}"
