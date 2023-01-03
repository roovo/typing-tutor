module StepTests exposing (all)

import Expect
import Step
import Test exposing (..)


all : Test
all =
    describe "Step Tests"
        [ isTypeableTests
        ]


isTypeableTests : Test
isTypeableTests =
    describe "isTypeable"
        [ test "returns True for a normal step" <|
            \() ->
                Step.init 'f'
                    |> Step.isTypeable
                    |> Expect.equal True
        , test "returns False for a Skip step" <|
            \() ->
                Step.initSkip "a"
                    |> Step.isTypeable
                    |> Expect.equal False
        , test "returns False for an End step" <|
            \() ->
                Step.initEnd
                    |> Step.isTypeable
                    |> Expect.equal False
        ]
