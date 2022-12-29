module ExerciseParser exposing (toSteps)

import Char
import List.Extra exposing (dropWhileRight)
import Parser as P exposing (Parser)
import Step exposing (Step)
import String


toSteps : String -> List Step
toSteps source =
    -- preProcess
    --     >> P.run lines
    --     >> postProcess
  []



-- PRE/POST PROCESSING


-- preProcess : String -> String
-- preProcess input =
--     input
--         |> String.trimRight
--         |> (\s -> String.append s "\n")
--
--
-- postProcess : Result (P.ParseErr ()) (P.ParseOk () (List Step)) -> List Step
-- postProcess =
--     extractResult
--         >> removeTrailingReturns
--         >> addEnd
--
--
-- extractResult : Result (P.ParseErr ()) (P.ParseOk () (List Step)) -> List Step
-- extractResult res =
--     case res of
--         Ok ( _, _, result ) ->
--             result
--
--         Err ( _, _, _ ) ->
--             []
--
--
-- removeTrailingReturns : List Step -> List Step
-- removeTrailingReturns =
--     dropWhileRight (\s -> Step.isSkipableWhitespace s || Step.isTypeableEnter s)
--
--
-- addEnd : List Step -> List Step
-- addEnd =
--     flip List.append [ Step.initEnd ]
--
--
--
-- -- PARSERS
--
--
-- enterChar : Char
-- enterChar =
--     (Char.fromCode 13)
--
--
-- lines : Parser s (List Step)
-- lines =
--     Parser.map (List.concatMap identity) (P.many line)
--
--
-- line : Parser s (List Step)
-- line =
--     whitespaceLine <|> lineWithContent
--
--
-- whitespaceLine : Parser s (List Step)
-- whitespaceLine =
--     liftA2 (++)
--         (P.manyTill spaces Char.eol)
--         -- (P.succeed [ Step.initSkip "\x0D" ])
--         (P.succeed [ Step.initSkip "\n" ])
--
--
-- lineWithContent : Parser s (List Step)
-- lineWithContent =
--     liftA2 (++)
--         (spacesThenCharacters <|> characters)
--         (P.succeed [ Step.init enterChar ])
--
--
-- spacesThenCharacters : Parser s (List Step)
-- spacesThenCharacters =
--     liftA2 (::) spaces characters
--
--
-- characters : Parser s (List Step)
-- characters =
--     P.manyTill character eol
--
--
-- eol : Parser s Char
-- eol =
--     P.regex " *" *> Char.eol
--
--
-- character : Parser s Step
-- character =
--     Parser.map Step.init Char.anyChar
--
--
-- spaces : Parser s Step
-- spaces =
--     Parser.map Step.initSkip (P.regex " +")
--
--
--
-- -- HELPERS
--
-- -- map2 : (a -> b -> c) -> Parser a -> Parser b -> Parser c
-- -- map2 fn parserA parserB =
-- --   map
-- --
-- -- liftA2 : (a -> b -> c) -> Parser s a -> Parser s b -> Parser s c
-- -- liftA2 f a b =
-- --     f <$> a <*> b
