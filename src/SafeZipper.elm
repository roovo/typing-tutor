module SafeZipper exposing (next, previous)

import List.Zipper as Zipper exposing (Zipper)


next : Zipper a -> Zipper a
next zipper =
    let
        next =
            Zipper.next zipper
    in
        case next of
            Nothing ->
                zipper

            Just z ->
                z


previous : Zipper a -> Zipper a
previous zipper =
    let
        previous =
            Zipper.previous zipper
    in
        case previous of
            Nothing ->
                zipper

            Just z ->
                z
