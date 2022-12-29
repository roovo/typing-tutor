module Route exposing (Route(..), fromUrl, urlFor)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = ExerciseListRoute
    | ExerciseRoute Int
    | ResultRoute Int


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url


urlFor : Route -> String
urlFor r =
    case r of
        ExerciseListRoute ->
            "/exercises"

        ExerciseRoute id ->
            "/exercises/" ++ String.fromInt id

        ResultRoute id ->
            "/results/" ++ String.fromInt id



-- PRIVATE


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map ExerciseListRoute (Parser.s "")
        , Parser.map ExerciseRoute (Parser.s "exercises" </> Parser.int)
        , Parser.map ExerciseListRoute (Parser.s "exercises")
        , Parser.map ResultRoute (Parser.s "results" </> Parser.int)
        ]
