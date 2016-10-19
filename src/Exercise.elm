module Exercise exposing (Exercise, accuracy, consume, init, isComplete, steps)

import Char
import Html exposing (Html)
import Html.Attributes
import MultiwayTree exposing (Tree(..))
import MultiwayTreeZipper as Zipper exposing (Zipper)
import Step exposing (Step, Direction(..), Status(..))
import String


backspaceChar =
    (Char.fromCode 8)


type alias Exercise =
    { steps : Zipper Step
    , typedCharacterCount : Int
    }


init : String -> Exercise
init source =
    { steps =
        ( source
            |> String.split ""
            |> List.map Step.init
            |> (List.foldr (\s t -> Tree s [ t ]) (Tree Step.end []))
        , []
        )
            |> setCurrentStatus
    , typedCharacterCount = 0
    }



steps : Exercise -> List Step
steps exercise =
    exercise.steps
        |> Zipper.goToRoot
        |> (Maybe.withDefault exercise.steps)
        |> fst
        |> MultiwayTree.flatten


consume : Char -> Exercise -> Exercise
consume char exercise =
    { exercise
        | steps =
            exercise.steps
                |> updateCurrentStep char
                |> moveZipper
                |> setCurrentStatus
        , typedCharacterCount = addCharacter char exercise.typedCharacterCount
    }


isComplete : Exercise -> Bool
isComplete exercise =
    exercise.steps
        |> Zipper.datum
        |> .status
        |> ((==) End)



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
    exercise
        |> steps
        |> List.length
        |> ((+) -1)


setCurrentStatus : Zipper Step -> Zipper Step
setCurrentStatus steps =
    steps
        |> Zipper.updateDatum Step.makeCurrent
        |> Maybe.withDefault steps


updateCurrentStep : Char -> Zipper Step -> Zipper Step
updateCurrentStep char steps =
    Zipper.updateDatum (Step.consume char) steps
        |> Maybe.withDefault steps


moveZipper : Zipper Step -> Zipper Step
moveZipper steps =
    let
        mover =
            steps
                |> Zipper.datum
                |> .moveTo
                |> zipperMover
    in
        steps
            |> mover
            |> Maybe.withDefault steps


zipperMover : Direction -> (Zipper Step -> Maybe (Zipper Step))
zipperMover direction =
    case direction of
        Next ->
            Zipper.goToChild 0

        Previous ->
            Zipper.goUp

        _ ->
            Just

addCharacter : Char -> Int -> Int
addCharacter char currentCount =
    if char == backspaceChar then
        currentCount
    else
        currentCount + 1
