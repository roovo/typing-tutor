module TestDecoders exposing (tests)

import Decoders
import ExerciseParser
import Expect
import Json.Decode as JD
import Step
import Test exposing (..)
import List.Zipper as Zipper exposing (Zipper)


tests : Test
tests =
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
                            , steps =
                                ExerciseParser.toSteps "a"
                                    |> Zipper.fromList
                                    |> Maybe.map (Zipper.update Step.makeCurrent)
                            , typedCharacterCount = 0
                            , timeTaken = 0
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