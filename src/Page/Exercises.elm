module Page.Exercises exposing
    ( Model
    , Msg
    , init
    , toSession
    , update
    )

import Api
import Api.Endpoint as Endpoint
import Exercise exposing (Exercise)
import Http
import Json.Decode as JD
import Json.Encode as JE
import Session exposing (Session)



-- MODEL


type alias Model =
    { session : Session
    , exercises : Status (List Exercise)
    }


type Status a
    = Loading
    | LoadingSlowly
    | Loaded a
    | Failed


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session
      , exercises = Loading
      }
    , fetchExercises session
    )


toSession : Model -> Session
toSession =
    .session



-- UPDATE


type Msg
    = CompletedExercisesFetch (Result Http.Error (List Exercise))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.exercises ) of
        ( CompletedExercisesFetch (Ok exercises), _ ) ->
            ( { model | exercises = Loaded exercises }, Cmd.none )

        ( CompletedExercisesFetch (Err _), _ ) ->
            ( { model | exercises = Failed }, Cmd.none )



-- HTTP


fetchExercises : Session -> Cmd Msg
fetchExercises session =
    JD.list Exercise.decoder
        |> Http.expectJson CompletedExercisesFetch
        |> Api.getMany (Endpoint.exercises (Session.apiRoot session))
