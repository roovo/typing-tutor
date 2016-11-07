module StepTests exposing (all)

import Char
import Expect
import Step exposing (Step, Direction(..), Status(..))
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
            [ test "returns a step with a status of Typeable and moveTo None" <|
                \() ->
                    Step.init "foo"
                        |> Expect.equal { content = "foo", status = Typeable, moveTo = None }
            ]
        , describe "initEnd"
            [ test "returns an empty step with a status of End and moveTo None" <|
                \() ->
                    Step.initEnd
                        |> Expect.equal { content = "", status = End, moveTo = None }
            ]
        , describe "initSkip"
            [ test "returns a step with a status of Skip and moveTo None" <|
                \() ->
                    Step.initSkip "foo"
                        |> Expect.equal { content = "foo", status = Skip, moveTo = None }
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
