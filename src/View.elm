module View exposing (view)

import Html exposing (Html)
import Model exposing (Model)
import Msg exposing (Msg)
import Routes exposing (Route(..))
import View.RunExerciseView


view : Model -> Html Msg
view model =
    Html.div
        []
        [ body model ]


body : Model -> Html Msg
body model =
    case model.route of
        ExerciseListRoute ->
            View.RunExerciseView.view model

        RunExerciseRoute ->
            View.RunExerciseView.view model

        NotFoundRoute ->
            Html.text "Sorry - not round these parts - 404"
