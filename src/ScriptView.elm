module ScriptView exposing (view)

import Html exposing (Html)
import Html.Attributes
import Script exposing (Script)


type CharacterClass
    = Current
    | Outstanding
    | Completed


view : Script -> Html msg
view script =
    Html.code
        []
        ((viewCompleted script)
            ++ [ viewCurent script ]
            ++ (viewRemaining script)
        )


viewCurent : Script -> Html msg
viewCurent script =
    viewCharacter Current (Script.current script)


viewCompleted : Script -> List (Html msg)
viewCompleted script =
    Script.completed script
        |> List.map (viewCharacter Completed)


viewRemaining : Script -> List (Html msg)
viewRemaining script =
    Script.remaining script
        |> List.map (viewCharacter Outstanding)


viewCharacter : CharacterClass -> String -> Html msg
viewCharacter class char =
    Html.span
        [ Html.Attributes.style
            (case class of
                Completed ->
                    [ ( "color", "black" )
                    ]

                Current ->
                    [ ( "color", "gray" )
                    , ( "background-color", "yellow" )
                    ]

                Outstanding ->
                    [ ( "color", "gray" )
                    ]
            )
        ]
        [ Html.text char ]
