module Script exposing (Script, chunks, init, tick)

import Chunk exposing (Chunk, Status(..), initChunk)
import Html exposing (Html)
import Html.Attributes
import List.Zipper as Zipper exposing (Zipper)
import String


-- MODEL


type alias Script =
    { typing : Maybe (Zipper Chunk)
    }


init : String -> Script
init toType =
    { typing =
        toType
            |> String.split ""
            |> List.map initChunk
            |> Zipper.fromList
            |> setCurrentStatus
    }


chunks : Script -> List Chunk
chunks script =
    script.typing
        |> Maybe.map Zipper.toList
        |> Maybe.withDefault []


tick : Char -> Script -> Script
tick char script =
    { script | typing = newCharacter char script.typing }


moveOnIfCorrect : Zipper Chunk -> Maybe (Zipper Chunk)
moveOnIfCorrect chunkZipper =
    let
        currentChunk =
            Zipper.current chunkZipper

        chunksRemain =
            chunkZipper
                |> Zipper.after
                |> List.isEmpty
                |> not
    in
        case ( Chunk.isCorrect currentChunk, chunksRemain ) of
            ( True, True ) ->
                chunkZipper
                    |> Zipper.next
                    |> setCurrentStatus

            ( _, _ ) ->
                Just chunkZipper


setCurrentStatus : Maybe (Zipper Chunk) -> Maybe (Zipper Chunk)
setCurrentStatus chunkZipper =
    chunkZipper
        |> Maybe.map (Zipper.update (\c -> { c | status = Current }))


newCharacter : Char -> Maybe (Zipper Chunk) -> Maybe (Zipper Chunk)
newCharacter char typing =
    case typing of
        Just chunkZipper ->
            chunkZipper
                |> Zipper.update (Chunk.updateStatus char)
                |> moveOnIfCorrect

        Nothing ->
            typing
