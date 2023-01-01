module Decoders exposing (attemptDecoder, attemptsDecoder, exerciseDecoder, exercisesDecoder)

import Attempt exposing (Attempt)
import Exercise exposing (Exercise)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (hardcoded, required)
import Time


exercisesDecoder : Decoder (List Exercise)
exercisesDecoder =
    Decode.list exerciseDecoder


exerciseDecoder : Decoder Exercise
exerciseDecoder =
    Decode.succeed Exercise.init
        |> required "id" Decode.int
        |> required "title" Decode.string
        |> required "text" Decode.string


attemptsDecoder : Decoder (List Attempt)
attemptsDecoder =
    Decode.list attemptDecoder


attemptDecoder : Decoder Attempt
attemptDecoder =
    Decode.succeed Attempt
        |> required "id" (Decode.nullable Decode.int)
        |> required "completedAt" (Decode.map Time.millisToPosix Decode.int)
        |> required "exerciseId" Decode.int
        |> required "accuracy" Decode.float
        |> required "wpm" Decode.float
        |> hardcoded []
