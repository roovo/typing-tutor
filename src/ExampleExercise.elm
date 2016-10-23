module ExampleExercise exposing (elm, three_lines)


three_lines =
    """Something to type
  that spans multiple lines
  in fact there are 3 of them!"""


elm =
    """backspaceChar =
    (Char.fromCode 8)


type alias Exercise =
    { steps : Maybe (Zipper Step)
    , typedCharacterCount : Int
    , timeTaken : Float
    }


init : String -> Exercise
init source =
    { steps =
        ExerciseParser.toSteps source
            |> Zipper.fromList
            |> Maybe.map setCurrentStatus
    , typedCharacterCount = 0
    , timeTaken = 0
    }


steps : Exercise -> List Step
steps exercise =
    exercise.steps
        |> Maybe.map Zipper.toList
        |> Maybe.withDefault []
  """
