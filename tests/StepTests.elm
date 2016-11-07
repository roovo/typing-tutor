module StepTests exposing (all)

import Char
import Expect
import Step exposing (Step, Status(..))
import Test exposing (..)


backspaceChar =
    (Char.fromCode 8)


all : Test
all =
    describe "Step Tests"
        [ initTests
        , isTypeableTests
        ]


initTests : Test
initTests =
    describe "Init Tests"
        [ describe "init"
            [ test "returns a step with a status of Typeable" <|
                \() ->
                    Step.init "foo"
                        |> Expect.equal { content = "foo", status = Typeable }
            ]
        , describe "initEnd"
            [ test "returns an empty step with a status of End" <|
                \() ->
                    Step.initEnd
                        |> Expect.equal { content = "", status = End }
            ]
        , describe "initSkip"
            [ test "returns a step with a status of Skip" <|
                \() ->
                    Step.initSkip "foo"
                        |> Expect.equal { content = "foo", status = Skip }
            ]
        ]


isTypeableTests : Test
isTypeableTests =
    describe "isTypeable"
        [ test "returns True for a normal step" <|
            \() ->
                Step.init "a"
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
