module UrlUpdate exposing (urlUpdate)

import Api
import Model exposing (Model)
import Msg exposing (Msg(..))
import Route exposing (Route(..))


cmdForModelRoute : Model -> Cmd Msg
cmdForModelRoute model =
    case model.route of
        ExerciseListRoute ->
            Api.fetchExercises model (always NoOp) <| GotExercises

        ExerciseRoute id ->
            Api.fetchExercise model id (always NoOp) <| GotExercise

        ResultRoute exerciseId ->
            Api.fetchAttempts model exerciseId (always NoOp) <| GotAttempts

        _ ->
            Cmd.none


urlUpdate : ( Route, Hop.Address ) -> Model -> ( Model, Cmd Msg )
urlUpdate ( route, address ) model =
    let
        _ =
            Debug.log "urlUpdate" ( route, address )

        newModel =
            { model
                | route = route
                , address = address
            }
    in
        ( newModel
        , cmdForModelRoute newModel
        )
