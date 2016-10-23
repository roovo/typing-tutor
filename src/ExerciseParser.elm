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
            |> removeTrailingWhitespace
            |> addEnd



-- PRIVATE FUNCTIONS


removeTrailingWhitespace : List Step -> List Step
removeTrailingWhitespace steps =
    steps
        |> dropWhileRight (\s -> s.content == "\n")


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
            , manyTill character Char.eol
            ]
        )
        (\r -> succeed (List.append r [ Step.init "\n" ]))


whitespaceAndCharacters : Parser (List Step)
whitespaceAndCharacters =
    sequence
        [ count 1 leadingWhitepace
        , manyTill character Char.eol
        ]
        |> map (\l -> List.concatMap identity l)


character : Parser Step
character =
    map Step.init (regex ".")


leadingWhitepace : Parser Step
leadingWhitepace =
    map Step.skip (regex " +")
