module DecoderTests exposing (all)

import Decoders
import Expect
import Json.Decode as JD
import Test exposing (..)


all : Test
all =
    describe "Decoders"
        [ attemptDecoderTests
        , exerciseDecoderTests
        ]


attemptDecoderTests : Test
attemptDecoderTests =
    describe "attemptDecoder"
        [ test "decodes an attempt" <|
            \() ->
                attemptJson
                    |> JD.decodeString Decoders.attemptDecoder
                    |> Expect.equal
                        (Ok
                            { id = Just 1
                            , completedAt = 1477511787975
                            , exerciseId = 2
                            , accuracy = 95.3
                            , wpm = 31.71
                            , events = []
                            }
                        )
        ]


exerciseDecoderTests : Test
exerciseDecoderTests =
    describe "exerciseDecoder"
        [ test "decodes an exercise" <|
            \() ->
                exerciseJson
                    |> JD.decodeString Decoders.exerciseDecoder
                    |> Expect.equal
                        (Ok
                            { id = 3
                            , title = "1 line"
                            , text = "a"
                            , events = []
                            }
                        )
        ]


attemptJson : String
attemptJson =
    """
{
  "exerciseId": 2,
  "completedAt": 1477511787975,
  "accuracy": 95.3,
  "wpm": 31.71,
  "id": 1
}
  """


exerciseJson : String
exerciseJson =
    """
{
  "title": "1 line",
  "text": "a",
  "id": 3
}
  """
