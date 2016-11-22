module Api exposing (createAttempt, fetchAttempts, fetchExercise, fetchExercises)

import Attempt exposing (Attempt)
import Decoders
import Event exposing (Event)
import Exercise exposing (Exercise)
import Http
import Json.Decode as JD
import Json.Encode as JE
import Model exposing (Model)
import Msg exposing (Msg)
import Task


fetchExercise : Model -> Int -> (Result Http.Error Exercise -> Msg) -> Cmd Msg
fetchExercise model id msg =
    get model ("/exercises/" ++ toString id) Decoders.exerciseDecoder msg


fetchExercises : Model -> (Result Http.Error (List Exercise) -> Msg) -> Cmd Msg
fetchExercises model msg =
    get model "/exercises" Decoders.exercisesDecoder msg


fetchAttempts : Model -> Int -> (Result Http.Error (List Attempt) -> Msg) -> Cmd Msg
fetchAttempts model exerciseId msg =
    get model ("/attempts?exerciseId=" ++ toString exerciseId ++ "&_sort=exerciseId&_order=DESC") Decoders.attemptsDecoder msg


createAttempt : Model -> Attempt -> (Result Http.Error Attempt -> Msg) -> Cmd Msg
createAttempt model attempt msg =
    post model "/attempts" (encodeAttempt attempt) Decoders.attemptDecoder msg


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


get : Model -> String -> JD.Decoder a -> (Result Http.Error a -> Msg) -> Cmd Msg
get model path decoder msg =
    Http.get
        (model.baseUrl ++ path)
        decoder
        |> Http.send msg


post : Model -> String -> JE.Value -> JD.Decoder a -> (Result Http.Error a -> Msg) -> Cmd Msg
post model path encoded decoder msg =
    Http.post
        (model.baseUrl ++ path)
        (Http.jsonBody encoded)
        decoder
        |> Http.send msg
