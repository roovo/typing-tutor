module Exercise exposing (Exercise, accuracy, consume, init, isComplete, steps)

import Char
import Html exposing (Html)
import Html.Attributes
import List.Zipper as Zipper exposing (Zipper)
import SafeZipper
import Step exposing (Step, Direction(..), Status(..))
import String


backspaceChar =
    (Char.fromCode 8)


type alias Exercise =
    { steps : Maybe (Zipper Step)
    , typedCharacterCount : Int
    }


init : String -> Exercise
init source =
    { steps =
        source
            |> String.split ""
            |> List.map Step.init
            |> flip List.append [ Step.end ]
            |> Zipper.fromList
            |> Maybe.map setCurrentStatus
    , typedCharacterCount = 0
    }


steps : Exercise -> List Step
steps exercise =
    exercise.steps
        |> Maybe.map Zipper.toList
        |> Maybe.withDefault []


consume : Char -> Exercise -> Exercise
consume char exercise =
    { exercise
        | steps =
            exercise.steps
                |> Maybe.map (updateCurrentStep char)
                |> Maybe.map moveZipper
                |> Maybe.map setCurrentStatus
        , typedCharacterCount = addCharacter char exercise.typedCharacterCount
    }


isComplete : Exercise -> Bool
isComplete exercise =
    exercise.steps
        |> Maybe.map Zipper.current
        |> Maybe.map .status
        |> Maybe.map ((==) End)
        |> Maybe.withDefault False


accuracy : Exercise -> Float
accuracy exercise =
    if exercise.typedCharacterCount == 0 then
        0
    else
        (toFloat <| exerciseCharacterCount exercise)
            / (toFloat <| exercise.typedCharacterCount)
            * 100



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
    steps
        |> (steps
                |> Zipper.current
                |> .moveTo
                |> zipperMover
           )


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
