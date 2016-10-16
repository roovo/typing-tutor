module Tests exposing (..)

import Test exposing (..)
import Expect
import Script


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
        , describe "tick"
            [ test "advances to the next character in the string" <|
                \() ->
                    Script.init "abcde"
                        |> Script.tick 'z'
                        |> Script.current
                        |> Expect.equal "b"
            ]
        ]


all : Test
all =
    describe "Tests"
        [ script
        ]
