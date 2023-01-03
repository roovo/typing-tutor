module AttemptTests exposing (all)

import Attempt
import Expect
import Json.Decode as JD
import Test exposing (..)
import Time


all : Test
all =
    describe "Decoders"
        [ decoderTests
        ]


decoderTests : Test
decoderTests =
    describe "decoder"
        [ test "decodes an attempt" <|
            \() ->
                """
{
  "exerciseId": 2,
  "completedAt": 1477511787975,
  "accuracy": 95.3,
  "wpm": 31.71,
  "id": 1
}
  """
                    |> JD.decodeString Attempt.decoder
                    |> Expect.equal
                        (Ok
                            { id = Just 1
                            , completedAt = Time.millisToPosix 1477511787975
                            , exerciseId = 2
                            , accuracy = 95.3
                            , wpm = 31.71
                            , events = []
                            }
                        )
        ]
