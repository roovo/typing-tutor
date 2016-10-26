module ExerciseParser exposing (toSteps)

import Char
import Combine
    exposing
        ( Parser
        , andThen
        , choice
        , count
        , many
        , manyTill
        , map
        , parse
        , regex
        , sequence
        , succeed
        )
import Combine.Char as Char
import List.Extra exposing (dropWhileRight)
import Step exposing (Step)
import String


toSteps string =
    let
        extractResult ( result, _ ) =
            Result.withDefault [] result
    in
        string
            |> String.trimRight
            |> flip String.append "\n"
            |> parse lines
            |> extractResult
            |> removeTrailingReturns
            |> addEnd



-- PRIVATE FUNCTIONS


removeTrailingReturns : List Step -> List Step
removeTrailingReturns steps =
    steps
        |> dropWhileRight (\s -> s.content == "\x0D")


addEnd : List Step -> List Step
addEnd steps =
    List.append steps [ Step.end ]


lines : Parser (List Step)
lines =
    many line
        |> map (\l -> List.concatMap identity l)


line : Parser (List Step)
line =
    andThen
        (choice
            [ whitespaceAndCharacters
            , characters
            ]
        )
        (\r -> succeed (List.append r [ Step.init "\x0D" ]))


whitespaceAndCharacters : Parser (List Step)
whitespaceAndCharacters =
    sequence
        [ count 1 spaces
        , characters
        ]
        |> map (\l -> List.concatMap identity l)


characters : Parser (List Step)
characters =
    manyTill character eol


eol : Parser Char
eol =
    regex " *"
        `andThen` \x -> Char.eol


character : Parser Step
character =
    map Step.init (regex ".")


spaces : Parser Step
spaces =
    map Step.skip (regex " +")
