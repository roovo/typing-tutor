module ExerciseParser exposing (character, leadingWhitepace, line)

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


-- prob make sense to add a \n to the end of the string
-- and use manyTill the end of line to parse each line


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
