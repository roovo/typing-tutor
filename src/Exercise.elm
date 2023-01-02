module Exercise exposing
    ( Exercise
    , Printable
    , Style(..)
    , accuracy
    , consume
    , decoder
    , init
    , isComplete
    , isRunning
    , printables
    , wpm
    )

import Char
import Event exposing (Event)
import ExerciseParser
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Pipeline as JDP
import List.Zipper as Zipper exposing (Zipper)
import SafeZipper
import Step exposing (Step)



-- MODEL


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



-- SERIALISATION


decoder : Decoder Exercise
decoder =
    JD.succeed init
        |> JDP.required "id" JD.int
        |> JDP.required "title" JD.string
        |> JDP.required "text" JD.string



-- INFO


accuracy : Exercise -> Float
accuracy exercise =
    case Event.howManyTyped exercise.events of
        0 ->
            0

        n ->
            (toFloat <| howManyCharacters exercise) / toFloat n * 100


printables : Exercise -> List Printable
printables exercise =
    steps exercise
        |> Zipper.first
        |> toInitialStep
        |> followEvents exercise.events
        |> setStyles


consume : Char -> Float -> Exercise -> Exercise
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


isRunning : Exercise -> Bool
isRunning exercise =
    not <| List.isEmpty exercise.events || isComplete exercise


wpm : Exercise -> Float
wpm exercise =
    case Event.timeTaken exercise.events of
        0 ->
            toFloat 0

        n ->
            howManyWords exercise / toFloat n * 60000



-- PRIVATE FUNCTIONS


lettersPerWord : Float
lettersPerWord =
    5.0


backspaceChar : Char
backspaceChar =
    Char.fromCode 8


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
    (toFloat <| howManyCharacters exercise) / lettersPerWord


logEvent : Char -> Float -> Exercise -> List Event
logEvent char timeTaken exercise =
    let
        newEvent =
            { char = char
            , timeTaken = round timeTaken
            }
    in
    newEvent :: exercise.events


followEvents : List Event -> Zipper Step -> ( Zipper Step, Int )
followEvents events initialSteps =
    let
        consumeEvent event ( steps1, errorCount ) =
            let
                currentStep =
                    Zipper.current steps1

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
                ( skipOver Next steps1, errorCount )

            else if atEnd then
                ( steps1, errorCount )

            else if isBackSpace && isErrorFree then
                ( skipOver Previous steps1, errorCount )

            else if isBackSpace then
                ( steps1, errorCount - 1 )

            else
                ( steps1, errorCount + 1 )
    in
    List.foldr consumeEvent ( initialSteps, 0 ) events


beforeStyles : Zipper Step -> List Printable
beforeStyles steps1 =
    let
        toPrintable step =
            { content = Step.toString step
            , style = Completed
            }
    in
    steps1
        |> Zipper.before
        |> List.map toPrintable


currentStyle : Int -> Zipper Step -> List Printable
currentStyle errorCount steps1 =
    let
        style =
            if errorCount <= 0 then
                Current

            else
                Error

        toPrintable step =
            { content = Step.toString step
            , style = style
            }

        current =
            Zipper.current steps1
    in
    [ toPrintable current ]


afterStyles : Int -> Zipper Step -> List Printable
afterStyles errorCount steps1 =
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
    steps1
        |> Zipper.after
        |> List.indexedMap toPrintable


setStyles : ( Zipper Step, Int ) -> List Printable
setStyles ( steps1, errorCount ) =
    beforeStyles steps1
        ++ currentStyle errorCount steps1
        ++ afterStyles errorCount steps1


skipOver : Direction -> Zipper Step -> Zipper Step
skipOver direction steps1 =
    let
        newSteps =
            zipperMover direction steps1
    in
    if Step.isSkipable (Zipper.current newSteps) then
        skipOver direction newSteps

    else
        newSteps


goForwardIfSkip : Zipper Step -> Zipper Step
goForwardIfSkip steps1 =
    let
        currentStep =
            Zipper.current steps1
    in
    if Step.isSkipable currentStep then
        skipOver Next steps1

    else
        steps1


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
