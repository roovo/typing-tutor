module Api exposing (fetchExercises)

import Decoders
import Exercise exposing (Exercise)
import Http
import Json.Decode as JD exposing ((:=))
import Model exposing (Model)
import Msg exposing (Msg)
import Task


fetchExercises : Model -> (Http.Error -> Msg) -> (List Exercise -> Msg) -> Cmd Msg
fetchExercises model errorMsg msg =
    get model "/exercises" Decoders.exercisesDecoder errorMsg msg


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
