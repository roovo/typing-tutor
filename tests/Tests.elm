module Tests exposing (..)

import Test exposing (..)
import Expect
import Script exposing (Status(..))


script : Test
script =
    describe "Script"
        [ describe "current"
            [ test "returns the first character of a new script" <|
                \() ->
                    Script.init "abcde"
                        |> Script.current
                        |> Expect.equal "a"
            , test "returns an empty string if the script is empty" <|
                \() ->
                    Script.init ""
                        |> Script.current
                        |> Expect.equal ""
            ]
        , describe "currentStatus"
            [ test "returns Waiting for a new script" <|
                \() ->
                    Script.init "abcde"
                        |> Script.currentStatus
                        |> Expect.equal Waiting
            , test "returns Waiting after a correct character is typed" <|
                \() ->
                    Script.init "abcd"
                        |> Script.tick 'a'
                        |> Script.currentStatus
                        |> Expect.equal Waiting
            , test "returns Error after an incorrect character is typed" <|
                \() ->
                    Script.init "abcd"
                        |> Script.tick 'b'
                        |> Script.currentStatus
                        |> Expect.equal Error
            , test "returns Waiting after an incorrect character is corrected" <|
                \() ->
                    Script.init "abcd"
                        |> Script.tick 'b'
                        |> Script.tick 'a'
                        |> Script.currentStatus
                        |> Expect.equal Waiting
            ]
        , describe "remaining"
            [ test "returns a List of the tail characters of a new script" <|
                \() ->
                    Script.init "abcde"
                        |> Script.remaining
                        |> Expect.equal [ "b", "c", "d", "e" ]
            , test "returns an empty List if the script is empty" <|
                \() ->
                    Script.init ""
                        |> Script.remaining
                        |> Expect.equal []
            ]
        , describe "completed"
            [ test "returns an empty List for a new script" <|
                \() ->
                    Script.init "abcde"
                        |> Script.completed
                        |> Expect.equal []
            , test "returns characters that have not been entered" <|
                \() ->
                    Script.init "abcde"
                        |> Script.tick 'a'
                        |> Script.tick 'b'
                        |> Script.completed
                        |> Expect.equal [ "a", "b" ]
            ]
        , describe "tick"
            [ test "advances to the next character in the string" <|
                \() ->
                    Script.init "abcde"
                        |> Script.tick 'a'
                        |> Script.current
                        |> Expect.equal "b"
            , test "won't advance if the wrong character is given" <|
                \() ->
                    Script.init "abc"
                        |> Script.tick 'a'
                        |> Script.tick 'c'
                        |> Script.current
                        |> Expect.equal "b"
            , test "won't advance past the end of the string" <|
                \() ->
                    Script.init "ab"
                        |> Script.tick 'a'
                        |> Script.tick 'b'
                        |> Script.current
                        |> Expect.equal "b"
            ]
        ]


all : Test
all =
    describe "Tests"
        [ script
        ]
