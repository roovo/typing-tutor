module ScriptView exposing (view)

import Html exposing (Html)
import Html.Attributes
import Script exposing (Script)
import Chunk exposing (Chunk, Status(..))


view : Script -> Html msg
view script =
    Html.div []
        (List.append
            (viewChunks script)
            (viewResults script)
        )


viewResults : Script -> List (Html msg)
viewResults script =
    if Script.isComplete script then
        [ Html.hr [] []
        , Html.div [] [ Html.text "Finished - yay!!" ]
        ]
    else
        []


viewChunks : Script -> List (Html msg)
viewChunks script =
    [ Html.code
        []
        (Script.toList script
            |> List.map viewChunk
        )
    ]


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

                End ->
                    []
            )
        ]
        [ Html.text chunk.content ]
