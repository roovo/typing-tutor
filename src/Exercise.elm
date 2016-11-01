module Exercise
    exposing
        ( Exercise
        , consume
        , init
        , isComplete
        , steps
        )

import Event exposing (Event)
import ExerciseParser
import Html exposing (Html)
import Html.Attributes
import List.Zipper as Zipper exposing (Zipper)
import SafeZipper
import Step exposing (Step, Direction(..), Status(..))
import String
import Time exposing (Time)


type alias Exercise =
    { id : Int
    , title : String
    , steps : Zipper Step
    , events : List Event
    }


init : Int -> String -> String -> Exercise
init id title text =
    { id = id
    , title = title
    , steps =
        ExerciseParser.toSteps text
            |> Zipper.fromList
            |> Maybe.withDefault (Zipper.singleton [ Step.initEnd ])
        -- |> toInitialStep
    , events = []
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
                , events = logEvent char timeTaken exercise
            }


logEvent : Char -> Time -> Exercise -> List Event
logEvent char timeTaken exercise =
    let
        currentStep =
            Zipper.current exercise.steps
    in
        case Step.isTypable currentStep of
            True ->
                let
                    newEvent =
                        { expected = currentStep.content
                        , actual = String.fromChar char
                        , timeTaken = round timeTaken
                        }
                in
                    newEvent :: exercise.events

            False ->
                exercise.events


isComplete : Exercise -> Bool
isComplete exercise =
    let
        isCurrentStatusEnd =
            Zipper.current >> .status >> (==) End
    in
        isCurrentStatusEnd exercise.steps



-- PRIVATE FUNCTIONS


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
