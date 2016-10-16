module ScriptView exposing (view)

import Html exposing (Html)
import Html.Attributes
import Script exposing (Script)
import Chunk exposing (Chunk, Status(..))


view : Script -> Html msg
view script =
    Html.code
        []
        (Script.chunks script
            |> List.map viewChunk
        )


viewChunk : Chunk -> Html msg
viewChunk chunk =
    Html.span
        [ Html.Attributes.style
            (case chunk.status of
                Completed ->
                    [ ( "color", "black" )
                    ]

                Current ->
                    [ ( "color", "black" )
                    , ( "background-color", "yellow" )
                    ]

                Error _ ->
                    [ ( "color", "gray" )
                    , ( "background-color", "red" )
                    ]

                Waiting ->
                    [ ( "color", "gray" )
                    ]
            )
        ]
        [ Html.text chunk.content ]
