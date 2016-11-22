module ExerciseParser exposing (toSteps)

import Char
import Combine as P exposing (Parser)
import Combine.Char as Char
import List.Extra exposing (dropWhileRight)
import Step exposing (Step)
import String


toSteps : String -> List Step
toSteps =
    preProcess
        >> P.parse lines
        >> postProcess



-- PRE/POST PROCESSING


preProcess : String -> String
preProcess =
    flip String.append "\n" << String.trimRight


postProcess : ( Result a (List Step), context ) -> List Step
postProcess =
    extractResult
        >> removeTrailingReturns
        >> addEnd


extractResult : ( Result a (List Step), context ) -> List Step
extractResult ( result, _ ) =
    Result.withDefault [] result


removeTrailingReturns : List Step -> List Step
removeTrailingReturns =
    dropWhileRight (\s -> Step.isSkipableWhitespace s || Step.isTypeableEnter s)


addEnd : List Step -> List Step
addEnd =
    flip List.append [ Step.initEnd ]



-- PARSERS


enterChar : Char
enterChar =
    (Char.fromCode 13)


lines : Parser (List Step)
lines =
    liftA (List.concatMap identity) (P.many line)


line : Parser (List Step)
line =
    whitespaceLine <|> lineWithContent


whitespaceLine : Parser (List Step)
whitespaceLine =
    liftA2 (++)
        (P.manyTill spaces Char.eol)
        (P.succeed [ Step.initSkip "\x0D" ])


lineWithContent : Parser (List Step)
lineWithContent =
    liftA2 (++)
        (spacesThenCharacters <|> characters)
        (P.succeed [ Step.init enterChar ])


spacesThenCharacters : Parser (List Step)
spacesThenCharacters =
    liftA2 (::) spaces characters


characters : Parser (List Step)
characters =
    P.manyTill character eol


eol : Parser Char
eol =
    P.regex " *" *> Char.eol


character : Parser Step
character =
    liftA Step.init Char.anyChar


spaces : Parser Step
spaces =
    liftA Step.initSkip (P.regex " +")



-- HELPERS


liftA : (a -> b) -> Parser a -> Parser b
liftA f a =
    f <$> a


liftA2 : (a -> b -> c) -> Parser a -> Parser b -> Parser c
liftA2 f a b =
    f <$> a <*> b
