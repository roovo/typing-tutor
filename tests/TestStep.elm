module TestStep exposing (..)

import Char
import Expect
import Step exposing (Step, Direction(..), Status(..))
import String
import Test exposing (..)


backspaceChar =
    (Char.fromCode 8)


step : Test
step =
    describe "Step"
        []
        -- [ describe "init"
        --     [ test "returns a Step with a status of Waiting and no moveTo" <|
        --         \() ->
        --             Step.init "foo"
        --                 |> Expect.equal { content = "foo", status = Waiting, moveTo = None }
        --     ]
        -- , describe "end"
        --     [ test "returns a Step with a status of End and no content or moveTo" <|
        --         \() ->
        --             Step.end
        --                 |> Expect.equal { content = "", status = End, moveTo = None }
        --     ]
        -- , describe "error"
        --     [ test "returns a Step with a status of 'Error Char'" <|
        --         \() ->
        --             Step.error 'x'
        --                 |> Expect.equal { content = String.fromChar backspaceChar, status = Error 'x', moveTo = None }
        --     ]
        -- , describe "consume"
        --       [ test "matching char returns status = Completed, moveTo = Next" <|
        --           \() ->
        --               Step.init "a"
        --                   |> Step.consume 'a'
        --                   |> Expect.equal { content = "a", status = Completed, moveTo = Next }
        --       , test "backspace returns status = Waiting, moveTo = Previous" <|
        --           \() ->
        --               Step.init "a"
        --                   |> Step.consume backspaceChar
        --                   |> Expect.equal { content = "a", status = Waiting, moveTo = Previous }
        --       , test "non-matching returns status = Waiting, moveTo = NewBranch" <|
        --           \() ->
        --               Step.init "a"
        --                   |> Step.consume 'b'
        --                   |> Expect.equal { content = "a", status = Waiting, moveTo = NewBranch }
        --       ]
        -- , describe "makeCurrent"
        --     [ test "sets it to Current if it was Waiting" <|
        --         \() ->
        --             Step.init "a"
        --                 |> Step.consume backspaceChar
        --                 |> Step.makeCurrent
        --                 |> .status
        --                 |> Expect.equal Current
        --     , test "sets it to Current if it was Completed" <|
        --         \() ->
        --             Step.init "a"
        --                 |> Step.consume 'a'
        --                 |> Step.makeCurrent
        --                 |> .status
        --                 |> Expect.equal Current
        --     , test "leaves it as Current if that's what it was" <|
        --         \() ->
        --             Step.init "a"
        --                 |> Step.consume 'a'
        --                 |> Step.makeCurrent
        --                 |> Step.makeCurrent
        --                 |> .status
        --                 |> Expect.equal Current
        --     , test "leaves it as End if that's what it was" <|
        --         \() ->
        --             Step.end
        --                 |> Step.makeCurrent
        --                 |> .status
        --                 |> Expect.equal End
        --     , test "leaves it as Error 'z' if that's what it was" <|
        --         \() ->
        --             Step.error 'z'
        --                 |> Step.makeCurrent
        --                 |> .status
        --                 |> Expect.equal (Error 'z')
        --     ]
        -- ]
