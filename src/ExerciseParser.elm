module ExerciseParser exposing (toSteps)

import Char
import Combine as P exposing (Parser, (<$>), (<*>), (*>), (<|>))
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


postProcess : Result (P.ParseErr ()) (P.ParseOk () (List Step)) -> List Step
postProcess =
    extractResult
        >> removeTrailingReturns
        >> addEnd


extractResult : Result (P.ParseErr ()) (P.ParseOk () (List Step)) -> List Step
extractResult res =
    case res of
        Ok ( _, _, result ) ->
            result

        Err ( _, _, _ ) ->
            []


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


lines : Parser s (List Step)
lines =
    liftA (List.concatMap identity) (P.many line)


line : Parser s (List Step)
line =
    whitespaceLine <|> lineWithContent


whitespaceLine : Parser s (List Step)
whitespaceLine =
    liftA2 (++)
        (P.manyTill spaces Char.eol)
        (P.succeed [ Step.initSkip "\x0D" ])


lineWithContent : Parser s (List Step)
lineWithContent =
    liftA2 (++)
        (spacesThenCharacters <|> characters)
        (P.succeed [ Step.init enterChar ])


spacesThenCharacters : Parser s (List Step)
spacesThenCharacters =
    liftA2 (::) spaces characters


characters : Parser s (List Step)
characters =
    P.manyTill character eol


eol : Parser s Char
eol =
    P.regex " *" *> Char.eol


character : Parser s Step
character =
    liftA Step.init Char.anyChar


spaces : Parser s Step
spaces =
    liftA Step.initSkip (P.regex " +")



-- HELPERS


liftA : (a -> b) -> Parser s a -> Parser s b
liftA f a =
    f <$> a


liftA2 : (a -> b -> c) -> Parser s a -> Parser s b -> Parser s c
liftA2 f a b =
    f <$> a <*> b
