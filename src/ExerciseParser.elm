module ExerciseParser exposing
    ( lineParser
    , lineWithContentParser
    , linesParser
    , spacesParser
    , spacesThenTypeablesParser
    , toSteps
    , typeablesParser
    , whitespaceLineParser
    )

import Char
import Parser as P exposing ((|=), Parser)
import Step exposing (Step)
import String


toSteps : String -> List Step
toSteps =
    preProcess >> P.run linesParser >> postProcess



-- PARSERS


lineParser : Parser (List Step)
lineParser =
    P.oneOf
        [ P.backtrackable lineWithContentParser
        , whitespaceLineParser
        ]


linesParser : Parser (List Step)
linesParser =
    let
        joinLines : List (List Step) -> List Step
        joinLines lineSteps =
            lineSteps
                |> List.intersperse [ Step.init (Char.fromCode 13) ]
                |> List.concat
    in
    P.sequence
        { start = ""
        , separator = "\n"
        , end = ""
        , spaces = P.succeed ()
        , item = lineParser
        , trailing = P.Optional
        }
        |> P.map joinLines


lineWithContentParser : Parser (List Step)
lineWithContentParser =
    P.oneOf
        [ spacesThenTypeablesParser
        , typeablesParser
        ]


spacesParser : Parser (List Step)
spacesParser =
    let
        toSkips : String -> Parser (List Step)
        toSkips possibleSpaces =
            if String.isEmpty possibleSpaces then
                P.problem "expected spaces, none found"

            else
                P.succeed [ Step.initSkip possibleSpaces ]
    in
    P.loop "" spacesHelp
        |> P.andThen toSkips


spacesThenTypeablesParser : Parser (List Step)
spacesThenTypeablesParser =
    P.succeed (\s t -> List.append s t)
        |= spacesParser
        |= typeablesParser


typeablesParser : Parser (List Step)
typeablesParser =
    let
        toTypeables : String -> Parser (List Step)
        toTypeables possibleTypeables =
            if String.isEmpty possibleTypeables then
                P.problem "expected typeable characters, none found"

            else
                possibleTypeables
                    |> String.toList
                    |> List.map Step.init
                    |> P.succeed
    in
    P.loop "" typeablesHelp
        |> P.andThen (String.trimRight >> toTypeables)


whitespaceLineParser : Parser (List Step)
whitespaceLineParser =
    let
        toSkips : String -> Parser (List Step)
        toSkips possibleSpaces =
            if String.isEmpty possibleSpaces then
                P.problem "expected whitespace line, not found"

            else
                P.succeed [ Step.initSkip "\u{000D}" ]
    in
    P.loop "" spacesHelp
        |> P.andThen toSkips



-- PRIVATE


addEnd : List Step -> List Step
addEnd steps =
    List.append steps [ Step.initEnd ]


isNotNewline : Char -> Bool
isNotNewline char =
    case char of
        '\n' ->
            False

        _ ->
            True


isSpace : Char -> Bool
isSpace char =
    case char of
        ' ' ->
            True

        _ ->
            False


postProcess : Result (List P.DeadEnd) (List Step) -> List Step
postProcess =
    Result.withDefault [] >> addEnd


preProcess : String -> String
preProcess input =
    input
        |> String.trimRight


spacesHelp : String -> Parser (P.Step String String)
spacesHelp spaces =
    P.oneOf
        [ P.getChompedString (P.chompIf isSpace)
            |> P.map (\space -> P.Loop (space ++ spaces))
        , P.succeed ()
            |> P.map (\_ -> P.Done spaces)
        ]


typeablesHelp : String -> Parser (P.Step String String)
typeablesHelp typeables =
    P.oneOf
        [ P.getChompedString (P.chompIf isNotNewline)
            |> P.map (\typeable -> P.Loop (typeables ++ typeable))
        , P.succeed ()
            |> P.map (\_ -> P.Done typeables)
        ]
