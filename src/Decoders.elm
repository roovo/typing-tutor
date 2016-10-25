module Decoders exposing (exercisesDecoder)

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
