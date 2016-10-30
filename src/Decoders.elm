module Decoders exposing (attemptDecoder, exerciseDecoder, exercisesDecoder)

import Attempt exposing (Attempt)
import Exercise exposing (Exercise)
import Json.Decode as JD exposing ((:=))


exercisesDecoder : JD.Decoder (List Exercise)
exercisesDecoder =
    JD.list exerciseDecoder


exerciseDecoder : JD.Decoder Exercise
exerciseDecoder =
    JD.object3 Exercise.init
        ("id" := JD.int)
        ("title" := JD.string)
        ("text" := JD.string)


attemptDecoder : JD.Decoder Attempt
attemptDecoder =
    JD.object6 Attempt
        (JD.maybe ("id" := JD.int))
        ("completedAt" := JD.float)
        ("exerciseId" := JD.int)
        ("accuracy" := JD.float)
        ("wpm" := JD.float)
        (JD.succeed [])
