module View.Exercises.List exposing (view)

import Exercise exposing (Exercise)
import Html exposing (Html)
import Html.Attributes
import Model exposing (Model)
import Msg exposing (Msg)
import Route exposing (Route(..))


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.h2 [] [ Html.text "Available exercies" ]
        , Html.div []
            [ exercisesTable model ]
        ]


exercisesTable : Model -> Html Msg
exercisesTable model =
    Html.ul []
        (List.map exerciseRow model.exercises)


exerciseRow : Exercise -> Html Msg
exerciseRow exercise =
    Html.li []
        [ Html.a
            [ Html.Attributes.href (Route.urlFor (ExerciseRoute exercise.id)) ]
            [ Html.text exercise.title ]
        ]