module Attempt exposing
    ( Attempt
    , decoder
    , encoder
    , init
    )

import Event exposing (Event)
import Exercise exposing (Exercise)
import Json.Decode as JD exposing (Decoder)
import Json.Decode.Pipeline as JDP
import Json.Encode as JE
import Time exposing (Posix)


type alias Attempt =
    { id : Maybe Int
    , completedAt : Posix
    , exerciseId : Int
    , accuracy : Float
    , wpm : Float
    , events : List Event
    }


init : Posix -> Exercise -> Attempt
init time exercise =
    { id = Nothing
    , completedAt = time
    , exerciseId = exercise.id
    , accuracy = Exercise.accuracy exercise
    , wpm = Exercise.wpm exercise
    , events = exercise.events
    }



-- SERIALISATION


decoder : Decoder Attempt
decoder =
    JD.succeed Attempt
        |> JDP.required "id" (JD.nullable JD.int)
        |> JDP.required "completedAt" (JD.map Time.millisToPosix JD.int)
        |> JDP.required "exerciseId" JD.int
        |> JDP.required "accuracy" JD.float
        |> JDP.required "wpm" JD.float
        |> JDP.hardcoded []


encoder : Attempt -> JE.Value
encoder attempt =
    JE.object
        [ ( "exerciseId", JE.int attempt.exerciseId )
        , ( "completedAt", JE.int <| Time.posixToMillis attempt.completedAt )
        , ( "accuracy", JE.float attempt.accuracy )
        , ( "wpm", JE.float attempt.wpm )
        , ( "events", JE.list Event.encoder attempt.events )
        ]
