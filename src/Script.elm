module Script exposing (Script, consume, init, toList)

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


toList : Script -> List Chunk
toList script =
    script.workBook
        |> Maybe.map Zipper.toList
        |> Maybe.withDefault []


consume : Char -> Script -> Script
consume char script =
    { script
        | workBook =
            script.workBook
                |> Maybe.map (updateCurrentChunk char)
                |> Maybe.map moveZipper
                |> Maybe.map setCurrentStatus
    }


updateCurrentChunk : Char -> Zipper Chunk -> Zipper Chunk
updateCurrentChunk char workbook =
    Zipper.update (Chunk.consume char) workbook


nextMove : Zipper Chunk -> Direction
nextMove chunkZipper =
    chunkZipper
        |> Zipper.current
        |> .moveTo


zipperMover : Direction -> (Zipper Chunk -> Zipper Chunk)
zipperMover direction =
    case direction of
        Next ->
            SafeZipper.next

        Previous ->
            SafeZipper.previous

        _ ->
            identity


moveZipper : Zipper Chunk -> Zipper Chunk
moveZipper chunkZipper =
    (chunkZipper
        |> Zipper.current
        |> .moveTo
        |> zipperMover
    )
    <|
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
