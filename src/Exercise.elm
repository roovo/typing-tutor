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
    { id : Int
    , title : String
    , steps : Zipper Step
    , typedCharacterCount : Int
    , timeTaken : Float
    }


init : Int -> String -> String -> Exercise
init id title text =
    { id = id
    , title = title
    , steps =
        ExerciseParser.toSteps text
            |> Zipper.fromList
            |> Maybe.withDefault (Zipper.singleton Step.initEnd)
            |> toInitialStep
    , typedCharacterCount = 0
    , timeTaken = 0
    }


steps : Exercise -> List Step
steps exercise =
    Zipper.toList exercise.steps


consume : Char -> Time -> Exercise -> Exercise
consume char timeTaken exercise =
    case isComplete exercise of
        True ->
            exercise

        False ->
            { exercise
                | steps =
                    exercise.steps
                        |> (updateCurrentStep char)
                        |> moveZipper
                        |> setCurrentStatus
                , typedCharacterCount = addCharacter char exercise.typedCharacterCount
                , timeTaken = exercise.timeTaken + timeTaken
            }


isComplete : Exercise -> Bool
isComplete exercise =
    let
        isCurrentStatusEnd =
            Zipper.current >> .status >> (==) End
    in
        isCurrentStatusEnd exercise.steps


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
    let
        nonSkippedStepCount =
            Zipper.toList
                >> List.filter Step.isTypable
                >> List.length
    in
        nonSkippedStepCount exercise.steps


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


goForwardIfSkip : Zipper Step -> Zipper Step
goForwardIfSkip steps =
    let
        currentStatus =
            (Zipper.current steps).status
    in
        if currentStatus == Skip then
            skipOver Next steps
        else
            steps


toInitialStep : Zipper Step -> Zipper Step
toInitialStep =
    goForwardIfSkip >> setCurrentStatus


zipperMover : Direction -> (Zipper Step -> Zipper Step)
zipperMover direction =
    case direction of
        Next ->
            SafeZipper.next

        Previous ->
            SafeZipper.previous

        _ ->
            identity
