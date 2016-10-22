module ExerciseParser exposing (leadingWhitepace)

import Combine exposing (Parser, map, regex)
import Step exposing (Step)


leadingWhitepace : Parser Step
leadingWhitepace =
    map Step.skip (regex " +")
