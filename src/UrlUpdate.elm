module UrlUpdate exposing (urlUpdate)

import Api
import Model exposing (Model)
import Msg exposing (Msg(..))
import Navigation
import Route exposing (Route(..))
import UrlParser


urlUpdate : Navigation.Location -> Model -> ( Model, Cmd Msg )
urlUpdate location model =
    let
        _ =
            Debug.log "urlUpdate" location

        newModel =
            { model
                | location = location
                , route = UrlParser.parsePath Route.route location
            }
    in
        ( newModel
        , cmdForModelRoute newModel
        )


cmdForModelRoute : Model -> Cmd Msg
cmdForModelRoute model =
    case model.route of
        Just ExerciseListRoute ->
            Api.fetchExercises model GotExercises

        Just (ExerciseRoute id) ->
            Api.fetchExercise model id GotExercise

        Just (ResultRoute exerciseId) ->
            Api.fetchAttempts model exerciseId GotAttempts

        Nothing ->
            Cmd.none
