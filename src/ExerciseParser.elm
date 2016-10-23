module ExerciseParser exposing (character, leadingWhitepace, line, lines, toSteps)

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
        , regex
        , sequence
        , succeed
        )
import Combine.Char as Char
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
            |> Combine.parse lines
            |> extractResult


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
