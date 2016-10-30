## add elm
curl -X "POST" "http://localhost:5000/exercises" \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -d $'{
  "title": "elm",
  "text": "backspaceChar = \\n    (Char.fromCode 8) \\n \\n \\ntype alias Exercise = \\n    { steps : Maybe (Zipper Step) \\n    , typedCharacterCount : Int \\n    , timeTaken : Float \\n    } \\n \\n \\ninit : String -> Exercise \\ninit source = \\n    { steps = \\n        ExerciseParser.toSteps source \\n            |> Zipper.fromList \\n            |> Maybe.map setCurrentStatus \\n    , typedCharacterCount = 0 \\n    , timeTaken = 0 \\n    } \\n \\n \\nsteps : Exercise -> List Step \\nsteps exercise = \\n    exercise.steps \\n        |> Maybe.map Zipper.toList \\n        |> Maybe.withDefault []\\n"
}'

## add 3 lines
curl -X "POST" "http://localhost:5000/exercises" \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -d $'{
  "title": "3 lines",
  "text": "  \\n  Something to type\\n  that spans multiple lines\\n  in fact there are 3 of them!"
}'

## add 1 line
curl -X "POST" "http://localhost:5000/exercises" \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -d $'{
  "title": "1 line",
  "text": "a line"
}'
