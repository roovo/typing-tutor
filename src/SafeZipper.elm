module SafeZipper exposing (next, previous)

import List.Zipper as Zipper exposing (Zipper)


next : Zipper a -> Zipper a
next zipper =
    Zipper.next zipper
        |> Maybe.withDefault zipper


previous : Zipper a -> Zipper a
previous zipper =
    Zipper.previous zipper
        |> Maybe.withDefault zipper
