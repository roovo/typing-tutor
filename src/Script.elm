module Script exposing (Script, chunks, init, tick)

import Char
import Chunk exposing (Chunk, Status(..))
import Html exposing (Html)
import Html.Attributes
import List.Zipper as Zipper exposing (Zipper)
import SafeZipper
import String


-- MODEL


backspaceChar =
    Char.fromCode 8


type alias Script =
    { workBook : Maybe (Zipper Chunk)
    }


init : String -> Script
init toType =
    { workBook =
        toType
            |> String.split ""
            |> List.map Chunk.init
            |> Zipper.fromList
            |> Maybe.map setCurrentStatus
    }


chunks : Script -> List Chunk
chunks script =
    script.workBook
        |> Maybe.map Zipper.toList
        |> Maybe.withDefault []


tick : Char -> Script -> Script
tick char script =
    { script | workBook = newCharacter char script.workBook }


newCharacter : Char -> Maybe (Zipper Chunk) -> Maybe (Zipper Chunk)
newCharacter char workBook =
    case workBook of
        Just chunkZipper ->
            chunkZipper
                |> Zipper.update (Chunk.parseChar char)
                |> moveZipper
                |> setCurrentStatus
                |> Just

        Nothing ->
            workBook


moveZipper : Zipper Chunk -> Zipper Chunk
moveZipper chunkZipper =
    let
        currentChunk =
            Zipper.current chunkZipper
    in
        if currentChunk.next > 0 then
            chunkZipper
                |> SafeZipper.next
        else if currentChunk.next < 0 then
            chunkZipper
                |> SafeZipper.previous
        else
            chunkZipper


chunksRemain : Zipper Chunk -> Bool
chunksRemain chunkZipper =
    chunkZipper
        |> Zipper.after
        |> List.isEmpty
        |> not


setCurrentStatus : Zipper Chunk -> Zipper Chunk
setCurrentStatus chunkZipper =
    let
        foo chunk =
            { chunk
                | status =
                    case chunk.status of
                        Waiting ->
                            Current

                        Completed ->
                            (if chunksRemain chunkZipper then
                                Current
                             else
                                chunk.status
                            )

                        _ ->
                            chunk.status
            }
    in
        Zipper.update foo chunkZipper
