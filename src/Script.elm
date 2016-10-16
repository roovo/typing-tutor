module Script exposing (Script, backspace, chunks, init, tick)

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


backspace : Script -> Script
backspace script =
    { script | typing = rewind script.typing }


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


moveBack : Zipper Chunk -> Maybe (Zipper Chunk)
moveBack chunkZipper =
    let
        beyondStart =
            chunkZipper
                |> Zipper.before
                |> List.isEmpty
                |> not
    in
        case beyondStart of
            True ->
                chunkZipper
                    |> Zipper.previous
                    |> setCurrentStatus

            _ ->
                Just chunkZipper
                    |> setCurrentStatus


rewind : Maybe (Zipper Chunk) -> Maybe (Zipper Chunk)
rewind typing =
    case typing of
        Just chunkZipper ->
            chunkZipper
                |> Zipper.update Chunk.resetStatus
                |> moveBack

        Nothing ->
            typing
