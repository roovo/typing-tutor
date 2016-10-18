module Script exposing (Script, chunks, init, tick)

import Char
import Chunk exposing (Chunk, Direction(..), Status(..))
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
init source =
    { workBook =
        source
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
    { script
        | workBook =
            script.workBook
                |> Maybe.map (updateCurrentChunk char)
                |> Maybe.map moveZipper
                |> Maybe.map setCurrentStatus
    }


updateCurrentChunk : Char -> Zipper Chunk -> Zipper Chunk
updateCurrentChunk char workbook =
    Zipper.update (Chunk.consumeChar char) workbook


moveZipper : Zipper Chunk -> Zipper Chunk
moveZipper chunkZipper =
    let
        currentChunk =
            Zipper.current chunkZipper
    in
        case currentChunk.moveTo of
            Next ->
                chunkZipper
                    |> SafeZipper.next
            Previous ->
                chunkZipper
                    |> SafeZipper.previous
            _ ->
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
