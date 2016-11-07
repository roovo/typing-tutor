module Exercise
    exposing
        ( Exercise
        , Printable
        , Style(..)
        , accuracy
        , consume
        , init
        , isComplete
        , printables
        , wpm
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


type Style
    = SCurrent
    | SError
    | SCompleted
    | SWaiting


type alias Printable =
    { content : String
    , style : Style
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
    , events = []
    }


accuracy : Exercise -> Float
accuracy exercise =
    case Event.howManyTyped exercise.events of
        0 ->
            0

        n ->
            (toFloat <| howManyCharacters exercise) / n * 100


printables : Exercise -> List Printable
printables exercise =
    exercise.steps
        |> Zipper.first
        |> toInitialStep
        |> followEvents exercise.events
        |> setStyles


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


isComplete : Exercise -> Bool
isComplete exercise =
    let
        isCurrentStatusEnd =
            Zipper.current >> .status >> (==) End
    in
        isCurrentStatusEnd exercise.steps


wpm : Exercise -> Float
wpm exercise =
    case Event.timeTaken exercise.events of
        0 ->
            0

        n ->
            howManyWords exercise / n * 60000



-- PRIVATE FUNCTIONS


lettersPerWord =
    5


howManyCharacters : Exercise -> Int
howManyCharacters exercise =
    exercise.steps
        |> Zipper.before
        |> List.filter Step.isTypable
        |> List.length


howManyWords : Exercise -> Float
howManyWords exercise =
    ((toFloat <| howManyCharacters exercise) / lettersPerWord)


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
                        { actual = String.fromChar char
                        , timeTaken = round timeTaken
                        }
                in
                    newEvent :: exercise.events

            False ->
                exercise.events


followEvents : List Event -> Zipper Step -> ( Zipper Step, Int )
followEvents events steps =
    let
        func event ( steps, errors ) =
            let
                currentStep =
                    Zipper.current steps

                matchingChar =
                    currentStep.content == event.actual

                isErrorFree =
                    errors <= 0

                backSpace =
                    event.actual == "\x08"

                atEnd =
                    currentStep
                        |> .status
                        |> (==) End
            in
                if matchingChar && isErrorFree then
                    ( skipOver Next steps, errors )
                else if atEnd then
                    ( steps, errors )
                else if backSpace && isErrorFree then
                    ( skipOver Previous steps, errors )
                else if backSpace then
                    ( steps, errors - 1 )
                else
                    ( steps, errors + 1 )
    in
        List.foldr func ( steps, 0 ) events


beforeStyles : Zipper Step -> List Printable
beforeStyles steps =
    let
        toPrintable step =
            { content = step.content
            , style = SCompleted
            }
    in
        steps
            |> Zipper.before
            |> List.map toPrintable


currentStyle : Int -> Zipper Step -> List Printable
currentStyle errorCount steps =
    let
        currentStyle =
            if errorCount <= 0 then
                SCurrent
            else
                SError

        toPrintable step =
            { content = step.content
            , style = currentStyle
            }

        current =
            Zipper.current steps
    in
        [ toPrintable current ]


afterStyles : Zipper Step -> List Printable
afterStyles steps =
    let
        toPrintable step =
            { content = step.content
            , style = SWaiting
            }
    in
        steps
            |> Zipper.after
            |> List.map toPrintable


setStyles : ( Zipper Step, Int ) -> List Printable
setStyles ( steps, errorCount ) =
    beforeStyles steps
        ++ currentStyle errorCount steps
        ++ afterStyles steps


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
