module Exercise
    exposing
        ( Exercise
        , accuracy
        , consume
        , init
        , isComplete
        , steps
        , timeTaken
        , wpm
        )

import Char
import ExerciseParser
import Html exposing (Html)
import Html.Attributes
import List.Zipper as Zipper exposing (Zipper)
import SafeZipper
import Step exposing (Step, Direction(..), Status(..))
import String
import Time exposing (Time)


backspaceChar =
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


consume : Char -> Time -> Exercise -> Exercise
consume char timeTaken exercise =
    case isComplete exercise of
        True ->
            exercise

        False ->
            { exercise
                | steps =
                    exercise.steps
                        |> Maybe.map (updateCurrentStep char)
                        |> Maybe.map moveZipper
                        |> Maybe.map setCurrentStatus
                , typedCharacterCount = addCharacter char exercise.typedCharacterCount
                , timeTaken = exercise.timeTaken + timeTaken
            }


isComplete : Exercise -> Bool
isComplete exercise =
    exercise.steps
        |> Maybe.map Zipper.current
        |> Maybe.map .status
        |> Maybe.map ((==) End)
        |> Maybe.withDefault False


timeTaken : Exercise -> Time
timeTaken exercise =
    exercise.timeTaken


accuracy : Exercise -> Float
accuracy exercise =
    if exercise.typedCharacterCount == 0 then
        0
    else
        (toFloat <| exerciseCharacterCount exercise)
            / (toFloat <| exercise.typedCharacterCount)
            * 100


wpm : Exercise -> Float
wpm exercise =
    let
        timeMins =
            timeTaken exercise / 60000
    in
        if timeMins == 0 then
            0
        else
            (toFloat (exerciseCharacterCount exercise) / 5) / timeMins



-- PRIVATE FUNCTIONS


exerciseCharacterCount : Exercise -> Int
exerciseCharacterCount exercise =
    exercise.steps
        |> Maybe.map Zipper.toList
        |> Maybe.map List.length
        |> Maybe.map (flip (-) 1)
        |> Maybe.withDefault 0


addCharacter : Char -> Int -> Int
addCharacter char currentCount =
    if char == backspaceChar then
        currentCount
    else
        currentCount + 1


updateCurrentStep : Char -> Zipper Step -> Zipper Step
updateCurrentStep char steps =
    Zipper.update (Step.consume char) steps


moveZipper : Zipper Step -> Zipper Step
moveZipper steps =
    let
        direction =
            steps
                |> Zipper.current
                |> .moveTo
    in
        skipOver direction steps


skipOver : Direction -> Zipper Step -> Zipper Step
skipOver direction steps =
    case direction of
        None ->
            steps

        _ ->
            let
                newSteps =
                    zipperMover direction steps
            in
                if (Zipper.current newSteps).status == Skip then
                    skipOver direction newSteps
                else
                    newSteps


setCurrentStatus : Zipper Step -> Zipper Step
setCurrentStatus steps =
    Zipper.update Step.makeCurrent steps


zipperMover : Direction -> (Zipper Step -> Zipper Step)
zipperMover direction =
    case direction of
        Next ->
            SafeZipper.next

        Previous ->
            SafeZipper.previous

        _ ->
            identity
