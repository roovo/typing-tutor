module ExerciseParser exposing
    ( emptyLineParser
    , lineParser
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
import Parser.Extra as PE
import Step exposing (Step)
import String


toSteps : String -> List Step
toSteps =
    preProcess >> P.run linesParser >> postProcess



-- PARSERS


emptyLineParser : Parser (List Step)
emptyLineParser =
    P.getChompedString (PE.lookAhead <| P.token "\n")
        |> P.map (\_ -> [ Step.initSkip "\n" ])


lineParser : Parser (List Step)
lineParser =
    P.oneOf
        [ P.backtrackable lineWithContentParser
        , whitespaceLineParser
        , emptyLineParser
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
                P.succeed [ Step.initSkip possibleSpaces ]
    in
    -- (P.succeed String.append
    --     |= P.loop "" spacesHelp
    --     |= P.getChompedString (P.chompWhile isNewline)
    -- )
    --     |> P.andThen toSkips
    P.loop "" spacesHelp
        |> P.andThen toSkips



-- PRIVATE


addEnd : List Step -> List Step
addEnd steps =
    List.append steps [ Step.initEnd ]


isNewline : Char -> Bool
isNewline char =
    case char of
        '\n' ->
            True

        _ ->
            False


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
        [ P.getChompedString (P.chompIf (not << isNewline))
            |> P.map (\typeable -> P.Loop (typeables ++ typeable))
        , P.succeed ()
            |> P.map (\_ -> P.Done typeables)
        ]



-- { start = ""
-- , separator = "\n"
-- , end = ""
-- , spaces = P.succeed ()
-- , item = lineParser
-- , trailing = P.Optional
-- }
-- sequence :
--     { separator : Parser ()
--     , item : Parser a
--     , trailing : Trailing
--     }
--     -> Parser (List a)
-- sequence i =
--             sequenceEnd i.item i.separator i.trailing
