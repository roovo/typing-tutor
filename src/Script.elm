module Script exposing (Script, consume, init, toList)

import Char
import Chunk exposing (Chunk, Direction(..), Status(..))
import Html exposing (Html)
import Html.Attributes
import List.Zipper as Zipper exposing (Zipper)
import SafeZipper
import String


-- MODEL


type alias Script =
    { workBook : Maybe (Zipper Chunk)
    }


init : String -> Script
init source =
    { workBook =
        source
            |> String.split ""
            |> List.map Chunk.init
            |> flip List.append [ Chunk.end ]
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


moveZipper : Zipper Chunk -> Zipper Chunk
moveZipper chunks =
    chunks
        |> (chunks
                |> Zipper.current
                |> .moveTo
                |> zipperMover
           )


setCurrentStatus : Zipper Chunk -> Zipper Chunk
setCurrentStatus chunks =
    Zipper.update Chunk.makeCurrent chunks


zipperMover : Direction -> (Zipper Chunk -> Zipper Chunk)
zipperMover direction =
    case direction of
        Next ->
            SafeZipper.next

        Previous ->
            SafeZipper.previous

        _ ->
            identity
