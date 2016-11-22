module View exposing (view)

import Html exposing (Html)
import Model exposing (Model)
import Msg exposing (Msg)
import Route exposing (Route(..))
import View.Exercises.List
import View.Exercises.Run
import View.Exercises.Result


view : Model -> Html Msg
view model =
    Html.div
        []
        [ body model ]


body : Model -> Html Msg
body model =
    case model.route of
        Just ExerciseListRoute ->
            View.Exercises.List.view model

        Just (ExerciseRoute id) ->
            View.Exercises.Run.view model

        Just (ResultRoute id) ->
            View.Exercises.Result.view model

        Nothing ->
            Html.text "Sorry - not round these parts - 404"
