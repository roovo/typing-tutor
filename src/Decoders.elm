module Decoders exposing (attemptDecoder, attemptsDecoder, exerciseDecoder, exercisesDecoder)

import Attempt exposing (Attempt)
import Exercise exposing (Exercise)
import Json.Decode as JD


exercisesDecoder : JD.Decoder (List Exercise)
exercisesDecoder =
    JD.list exerciseDecoder


exerciseDecoder : JD.Decoder Exercise
exerciseDecoder =
    JD.map3 Exercise.init
        (JD.field "id" JD.int)
        (JD.field "title" JD.string)
        (JD.field "text" JD.string)


attemptsDecoder : JD.Decoder (List Attempt)
attemptsDecoder =
    JD.list attemptDecoder


attemptDecoder : JD.Decoder Attempt
attemptDecoder =
    JD.map6 Attempt
        (JD.maybe (JD.field "id" JD.int))
        (JD.field "completedAt" JD.float)
        (JD.field "exerciseId" JD.int)
        (JD.field "accuracy" JD.float)
        (JD.field "wpm" JD.float)
        (JD.succeed [])
