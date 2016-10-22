module TestStep exposing (..)

import Char
import Expect
import Step exposing (Step, Direction(..), Status(..))
import Test exposing (..)


backspaceChar =
    (Char.fromCode 8)


step : Test
step =
    describe "Step"
        [ describe "init"
            [ test "returns a step with a status of Waiting and moveTo None" <|
                \() ->
                    Step.init "foo"
                        |> Expect.equal { content = "foo", status = Waiting, moveTo = None }
            ]
        , describe "end"
            [ test "returns an empty step with a status of End and moveTo None" <|
                \() ->
                    Step.end
                        |> Expect.equal { content = "", status = End, moveTo = None }
            ]
        , describe "skip"
            [ test "returns a step with a status of Skip and moveTo None" <|
                \() ->
                    Step.skip "foo"
                        |> Expect.equal { content = "foo", status = Skip, moveTo = None }
            ]
        , describe "consume"
            [ describe "no Errors"
                [ test "matching char returns status = Completed, moveTo = Next" <|
                    \() ->
                        Step.init "a"
                            |> Step.consume 'a'
                            |> Expect.equal { content = "a", status = Completed, moveTo = Next }
                , test "backspace returns status = Waiting, moveTo = Previous" <|
                    \() ->
                        Step.init "a"
                            |> Step.consume backspaceChar
                            |> Expect.equal { content = "a", status = Waiting, moveTo = Previous }
                , test "non-matching returns status = Error 1, moveTo = None" <|
                    \() ->
                        Step.init "a"
                            |> Step.consume 'b'
                            |> Expect.equal { content = "a", status = Error 1, moveTo = None }
                ]
            , describe "with Error 1 (single error)"
                [ test "matching char returns status = Error 2, moveTo = None" <|
                    \() ->
                        Step.init "a"
                            |> Step.consume 'b'
                            |> Step.consume 'a'
                            |> Expect.equal { content = "a", status = Error 2, moveTo = None }
                , test "backspace returns status = Waiting, moveTo = None" <|
                    \() ->
                        Step.init "a"
                            |> Step.consume 'b'
                            |> Step.consume backspaceChar
                            |> Expect.equal { content = "a", status = Waiting, moveTo = None }
                , test "non-matching returns status = Error 2, moveTo = None" <|
                    \() ->
                        Step.init "a"
                            |> Step.consume 'b'
                            |> Step.consume 'b'
                            |> Expect.equal { content = "a", status = Error 2, moveTo = None }
                ]
            , describe "with Error 2 (multiple errora)"
                [ test "matching char returns status = Error 3, moveTo = None" <|
                    \() ->
                        Step.init "a"
                            |> Step.consume 'b'
                            |> Step.consume 'b'
                            |> Step.consume 'a'
                            |> Expect.equal { content = "a", status = Error 3, moveTo = None }
                , test "backspace returns status = Error 1, moveTo = None" <|
                    \() ->
                        Step.init "a"
                            |> Step.consume 'b'
                            |> Step.consume 'b'
                            |> Step.consume backspaceChar
                            |> Expect.equal { content = "a", status = Error 1, moveTo = None }
                , test "non-matching returns status = Error 3, moveTo = None" <|
                    \() ->
                        Step.init "a"
                            |> Step.consume 'b'
                            |> Step.consume 'b'
                            |> Step.consume 'b'
                            |> Expect.equal { content = "a", status = Error 3, moveTo = None }
                ]
            ]
        , describe "makeCurrent"
            [ test "sets it to Current if it was Waiting" <|
                \() ->
                    Step.init "a"
                        |> Step.consume backspaceChar
                        |> Step.makeCurrent
                        |> .status
                        |> Expect.equal Current
            , test "sets it to Current if it was Completed" <|
                \() ->
                    Step.init "a"
                        |> Step.consume 'a'
                        |> Step.makeCurrent
                        |> .status
                        |> Expect.equal Current
            , test "leaves it as Current if that's what it was" <|
                \() ->
                    Step.init "a"
                        |> Step.consume 'a'
                        |> Step.makeCurrent
                        |> Step.makeCurrent
                        |> .status
                        |> Expect.equal Current
            , test "leaves it as End if that's what it was" <|
                \() ->
                    Step.end
                        |> Step.makeCurrent
                        |> .status
                        |> Expect.equal End
            , test "leaves it as Error 1 if that's what it was" <|
                \() ->
                    Step.init "a"
                        |> Step.consume 'b'
                        |> Step.makeCurrent
                        |> .status
                        |> Expect.equal (Error 1)
            ]
        ]