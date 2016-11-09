module Api exposing (createAttempt, fetchAttempts, fetchExercise, fetchExercises)

import Attempt exposing (Attempt)
import Decoders
import Event exposing (Event)
import Exercise exposing (Exercise)
import Http
import Json.Decode as JD exposing ((:=))
import Json.Encode as JE
import Model exposing (Model)
import Msg exposing (Msg)
import Task


fetchExercise : Model -> Int -> (Http.Error -> Msg) -> (Exercise -> Msg) -> Cmd Msg
fetchExercise model id errorMsg msg =
    get model ("/exercises/" ++ toString id) Decoders.exerciseDecoder errorMsg msg


fetchExercises : Model -> (Http.Error -> Msg) -> (List Exercise -> Msg) -> Cmd Msg
fetchExercises model errorMsg msg =
    get model "/exercises" Decoders.exercisesDecoder errorMsg msg


fetchAttempts : Model -> Int -> (Http.Error -> Msg) -> (List Attempt -> Msg) -> Cmd Msg
fetchAttempts model exerciseId errorMsg msg =
    get model ("/attempts?exerciseId=" ++ toString exerciseId) Decoders.attemptsDecoder errorMsg msg


createAttempt : Model -> Attempt -> (Http.Error -> Msg) -> (Attempt -> Msg) -> Cmd Msg
createAttempt model attempt errorMsg msg =
    post model "/attempts" (encodeAttempt attempt) Decoders.attemptDecoder errorMsg msg


encodeAttempt : Attempt -> JE.Value
encodeAttempt attempt =
    JE.object
        [ ( "exerciseId", JE.int attempt.exerciseId )
        , ( "completedAt", JE.float attempt.completedAt )
        , ( "accuracy", JE.float attempt.accuracy )
        , ( "wpm", JE.float attempt.wpm )
        , ( "events", JE.list (List.map encodeEvent attempt.events) )
        ]


encodeEvent : Event -> JE.Value
encodeEvent event =
    tuple2Encoder
        JE.string
        JE.int
        ( toString event.char, event.timeTaken )


tuple2Encoder : (a -> JE.Value) -> (b -> JE.Value) -> ( a, b ) -> JE.Value
tuple2Encoder enc1 enc2 ( val1, val2 ) =
    JE.list [ enc1 val1, enc2 val2 ]


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


post : Model -> String -> JE.Value -> JD.Decoder a -> (Http.Error -> Msg) -> (a -> Msg) -> Cmd Msg
post model path encoded decoder errorMsg msg =
    let
        request =
            defaultRequest model path
    in
        Http.send Http.defaultSettings
            { request
                | verb = "POST"
                , body = Http.string (encoded |> JE.encode 0)
            }
            |> Http.fromJson decoder
            |> Task.perform errorMsg msg
