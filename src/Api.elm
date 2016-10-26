module Api exposing (createResult, fetchExercise, fetchExercises)

import Decoders
import Exercise exposing (Exercise)
import Http
import Json.Decode as JD exposing ((:=))
import Model exposing (Model)
import Msg exposing (Msg)
import Task


fetchExercise : Model -> Int -> (Http.Error -> Msg) -> (Exercise -> Msg) -> Cmd Msg
fetchExercise model id errorMsg msg =
    get model ("/exercises/" ++ toString id) Decoders.exerciseDecoder errorMsg msg


fetchExercises : Model -> (Http.Error -> Msg) -> (List Exercise -> Msg) -> Cmd Msg
fetchExercises model errorMsg msg =
    get model "/exercises" Decoders.exercisesDecoder errorMsg msg


createResult : Model -> (Http.Error -> Msg) -> (Exercise -> Msg) -> Cmd Msg
createResult model errorMsg msg =
    get model "/exercises" Decoders.exerciseDecoder errorMsg msg


defaultRequest : Model -> String -> Http.Request
defaultRequest model path =
    { verb = "GET"
    , url = model.baseUrl ++ path
    , body = Http.empty
    , headers = [ ( "Content-Type", "application/json" ) ]
    }


get : Model -> String -> JD.Decoder a -> (Http.Error -> Msg) -> (a -> Msg) -> Cmd Msg
get model path decoder errorMsg msg =
    Http.send Http.defaultSettings
        (defaultRequest model path)
        |> Http.fromJson decoder
        |> Task.perform errorMsg msg
