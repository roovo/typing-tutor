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

import Char
import Event exposing (Event)
import ExerciseParser
import List.Zipper as Zipper exposing (Zipper)
import SafeZipper
import Step exposing (Step)
import Time exposing (Time)


type alias Exercise =
    { id : Int
    , title : String
    , text : String
    , events : List Event
    }


type Style
    = Current
    | Error
    | Completed
    | Waiting


type alias Printable =
    { content : String
    , style : Style
    }


init : Int -> String -> String -> Exercise
init id title text =
    { id = id
    , title = title
    , text = text
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
    steps exercise
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
                | events = logEvent char timeTaken exercise
            }


isComplete : Exercise -> Bool
isComplete exercise =
    steps exercise
        |> Zipper.first
        |> toInitialStep
        |> followEvents exercise.events
        |> Tuple.first
        |> Zipper.current
        |> Step.isEnd


wpm : Exercise -> Float
wpm exercise =
    case Event.timeTaken exercise.events of
        0 ->
            0

        n ->
            howManyWords exercise / n * 60000



-- PRIVATE FUNCTIONS


lettersPerWord : Float
lettersPerWord =
    5


backspaceChar : Char
backspaceChar =
    (Char.fromCode 8)


type Direction
    = Next
    | Previous


steps : Exercise -> Zipper Step
steps exercise =
    ExerciseParser.toSteps exercise.text
        |> Zipper.fromList
        |> Maybe.withDefault (Zipper.singleton Step.initEnd)
        |> toInitialStep


howManyCharacters : Exercise -> Int
howManyCharacters exercise =
    steps exercise
        |> Zipper.first
        |> toInitialStep
        |> followEvents exercise.events
        |> Tuple.first
        |> Zipper.before
        |> List.filter Step.isTypeable
        |> List.length


howManyWords : Exercise -> Float
howManyWords exercise =
    ((toFloat <| howManyCharacters exercise) / lettersPerWord)


logEvent : Char -> Time -> Exercise -> List Event
logEvent char timeTaken exercise =
    let
        newEvent =
            { char = char
            , timeTaken = round timeTaken
            }
    in
        newEvent :: exercise.events


followEvents : List Event -> Zipper Step -> ( Zipper Step, Int )
followEvents events steps =
    let
        consumeEvent event ( steps, errorCount ) =
            let
                currentStep =
                    Zipper.current steps

                isMatchingChar =
                    Step.matchesTyped event.char currentStep

                isErrorFree =
                    errorCount <= 0

                isBackSpace =
                    event.char == backspaceChar

                atEnd =
                    Step.isEnd currentStep
            in
                if isMatchingChar && isErrorFree then
                    ( skipOver Next steps, errorCount )
                else if atEnd then
                    ( steps, errorCount )
                else if isBackSpace && isErrorFree then
                    ( skipOver Previous steps, errorCount )
                else if isBackSpace then
                    ( steps, errorCount - 1 )
                else
                    ( steps, errorCount + 1 )
    in
        List.foldr consumeEvent ( steps, 0 ) events


beforeStyles : Zipper Step -> List Printable
beforeStyles steps =
    let
        toPrintable step =
            { content = Step.toString step
            , style = Completed
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
                Current
            else
                Error

        toPrintable step =
            { content = Step.toString step
            , style = currentStyle
            }

        current =
            Zipper.current steps
    in
        [ toPrintable current ]


afterStyles : Int -> Zipper Step -> List Printable
afterStyles errorCount steps =
    let
        toPrintable index step =
            if index < (errorCount - 1) then
                { content = Step.toString step
                , style = Error
                }
            else
                { content = Step.toString step
                , style = Waiting
                }
    in
        steps
            |> Zipper.after
            |> List.indexedMap toPrintable


setStyles : ( Zipper Step, Int ) -> List Printable
setStyles ( steps, errorCount ) =
    beforeStyles steps
        ++ currentStyle errorCount steps
        ++ afterStyles errorCount steps


skipOver : Direction -> Zipper Step -> Zipper Step
skipOver direction steps =
    let
        newSteps =
            zipperMover direction steps
    in
        if Step.isSkipable (Zipper.current newSteps) then
            skipOver direction newSteps
        else
            newSteps


goForwardIfSkip : Zipper Step -> Zipper Step
goForwardIfSkip steps =
    let
        currentStep =
            Zipper.current steps
    in
        if Step.isSkipable currentStep then
            skipOver Next steps
        else
            steps


toInitialStep : Zipper Step -> Zipper Step
toInitialStep =
    goForwardIfSkip


zipperMover : Direction -> (Zipper Step -> Zipper Step)
zipperMover direction =
    case direction of
        Next ->
            SafeZipper.next

        Previous ->
            SafeZipper.previous
