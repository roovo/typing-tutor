module ExerciseParser exposing (character, leadingWhitepace, toSteps)

import Combine exposing (Parser, choice, count, many, map, regex, sequence)
import Step exposing (Step)


-- prob make sense to add a \n to the end of the string
-- and use manyTill the end of line to parse each line


toSteps : Parser (List Step)
toSteps =
    choice
        [ whitespaceAndCharacters
        , many character
        ]


whitespaceAndCharacters : Parser (List Step)
whitespaceAndCharacters =
    sequence
        [ count 1 leadingWhitepace
        , many character
        ]
        |> map (\l -> List.concatMap identity l)


character : Parser Step
character =
    map Step.init (regex ".")


leadingWhitepace : Parser Step
leadingWhitepace =
    map Step.skip (regex " +")
