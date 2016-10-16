module ScriptView exposing (view)

import Html exposing (Html)
import Html.Attributes
import List.Zipper as Zipper exposing (Zipper)
import Script exposing (Script)


type CharacterClass
    = Current
    | Outstanding


view : Script -> Html msg
view script =
    Html.code
        []
        (case script.typing of
            Just zippedString ->
                ([ viewCurent zippedString ] ++ (viewAfter zippedString))

            Nothing ->
                [ Html.text "" ]
        )


viewCurent : Zipper String -> Html msg
viewCurent zippedString =
    viewCharacter Current (Zipper.current zippedString)


viewAfter : Zipper String -> List (Html msg)
viewAfter zippedString =
    Zipper.after zippedString
        |> List.map (viewCharacter Outstanding)


viewCharacter : CharacterClass -> String -> Html msg
viewCharacter class char =
    Html.span
        [ Html.Attributes.style
            (case class of
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
