## add elm
curl -X "POST" "http://localhost:5000/exercises" \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -d $'{
  "title": "elm",
  "text": "backspaceChar = \\n    (Char.fromCode 8) \\n \\n \\ntype alias Exercise = \\n    { steps : Maybe (Zipper Step) \\n    , typedCharacterCount : Int \\n    , timeTaken : Float \\n    } \\n \\n \\ninit : String -> Exercise \\ninit source = \\n    { steps = \\n        ExerciseParser.toSteps source \\n            |> Zipper.fromList \\n            |> Maybe.map setCurrentStatus \\n    , typedCharacterCount = 0 \\n    , timeTaken = 0 \\n    } \\n \\n \\nsteps : Exercise -> List Step \\nsteps exercise = \\n    exercise.steps \\n        |> Maybe.map Zipper.toList \\n        |> Maybe.withDefault []\\n"
}'

## add elm_long
curl -X "POST" "http://localhost:5000/exercises" \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -d "{\"title\":\"elm long\",\"text\":\"module Step\\n    exposing\\n        ( Step\\n        , toString\\n        , init\\n        , initEnd\\n        , initSkip\\n        , isEnd\\n        , isSkipable\\n        , isSkipableWhitespace\\n        , isTypeable\\n        , isTypeableEnter\\n        , matchesTyped\\n        )\\n\\nimport Char\\nimport String\\n\\n\\nbackspaceCode : Int\\nbackspaceCode =\\n    8\\n\\n\\nenterChar : Char\\nenterChar =\\n    (Char.fromCode 13)\\n\\n\\ntype Step\\n    = Typeable Char\\n    | Skip String\\n    | End\\n\\n\\ninit : Char -> Step\\ninit char =\\n    Typeable char\\n\\n\\ninitSkip : String -> Step\\ninitSkip string =\\n    Skip string\\n\\n\\ninitEnd : Step\\ninitEnd =\\n    End\\n\\n\\ntoString : Step -> String\\ntoString step =\\n    case step of\\n        Typeable char ->\\n            String.fromChar char\\n\\n        Skip string ->\\n            string\\n\\n        End ->\\n            \\\"\\\"\\n\\n\\nmatchesTyped : Char -> Step -> Bool\\nmatchesTyped char step =\\n    case step of\\n        Typeable actual ->\\n            actual == char\\n\\n        _ ->\\n            False\\n\\n\\nisEnd : Step -> Bool\\nisEnd step =\\n    case step of\\n        End ->\\n            True\\n\\n        _ ->\\n            False\\n\\n\\nisSkipable : Step -> Bool\\nisSkipable step =\\n    case step of\\n        Skip _ ->\\n            True\\n\\n        _ ->\\n            False\\n\\n\\nisSkipableWhitespace : Step -> Bool\\nisSkipableWhitespace step =\\n    case step of\\n        Skip string ->\\n            String.length (String.trim string) == 0\\n\\n        _ ->\\n            False\\n\\n\\nisTypeable : Step -> Bool\\nisTypeable step =\\n    case step of\\n        Typeable _ ->\\n            True\\n\\n        _ ->\\n            False\\n\\n\\nisTypeableEnter : Step -> Bool\\nisTypeableEnter step =\\n    case step of\\n        Typeable char ->\\n            char == enterChar\\n\\n        _ ->\\n            False\\n\"}"

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

## add 3 lines long lead in
curl -X "POST" "http://localhost:5000/exercises" \
     -H "Content-Type: application/json" \
     -H "Accept: application/json" \
     -d $'{
  "title": "3 lines long lead in",
  "text": "\\n\\n\\n\\n\\n\\n\\n\\n\\n\\n\\n\\n\\n\\n\\n  Something to type\\n\\n\\n\\n\\n\\n\\n\\n\\n  that spans multiple lines\\n  in fact there are 3 of them!"
}'
