module SafeZipperTests exposing (all)

import SafeZipper
import Expect
import Test exposing (..)
import List.Zipper as Zipper


all : Test
all =
    describe "SafeZipper"
        [ nextTests
        , previousTests
        ]


nextTests : Test
nextTests =
    describe "next"
        [ test "it moves along the list" <|
            \() ->
                Zipper.fromList [ 1, 2, 3 ]
                    |> Maybe.map SafeZipper.next
                    |> Maybe.map Zipper.current
                    |> Expect.equal (Just 2)
        , test "it doesn't go past the end of the list" <|
            \() ->
                Zipper.fromList [ 1, 2, 3 ]
                    |> Maybe.map SafeZipper.next
                    |> Maybe.map SafeZipper.next
                    |> Maybe.map SafeZipper.next
                    |> Maybe.map Zipper.toList
                    |> Expect.equal (Just [ 1, 2, 3 ])
        , test "sticks to the end of the list" <|
            \() ->
                Zipper.fromList [ 1, 2, 3 ]
                    |> Maybe.map SafeZipper.next
                    |> Maybe.map SafeZipper.next
                    |> Maybe.map SafeZipper.next
                    |> Maybe.map SafeZipper.next
                    |> Maybe.map Zipper.current
                    |> Expect.equal (Just 3)
        ]


previousTests : Test
previousTests =
    describe "previous"
        [ test "it moves back along the list" <|
            \() ->
                Zipper.fromList [ 1, 2, 3 ]
                    |> Maybe.map SafeZipper.next
                    |> Maybe.map SafeZipper.previous
                    |> Maybe.map Zipper.current
                    |> Expect.equal (Just 1)
        , test "it doesn't go past the beginning of the list" <|
            \() ->
                Zipper.fromList [ 1, 2, 3 ]
                    |> Maybe.map SafeZipper.previous
                    |> Maybe.map SafeZipper.previous
                    |> Maybe.map Zipper.toList
                    |> Expect.equal (Just [ 1, 2, 3 ])
        , test "sticks to the start of the list" <|
            \() ->
                Zipper.fromList [ 1, 2, 3 ]
                    |> Maybe.map SafeZipper.next
                    |> Maybe.map SafeZipper.previous
                    |> Maybe.map SafeZipper.previous
                    |> Maybe.map SafeZipper.previous
                    |> Maybe.map Zipper.current
                    |> Expect.equal (Just 1)
        ]
