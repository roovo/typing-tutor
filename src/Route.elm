module Route exposing (Route(..), fromUrl, urlFor)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)


type Route
    = Attempts Int
    | Exercises
    | Exercise Int


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url


urlFor : Route -> String
urlFor r =
    case r of
        Exercises ->
            "/exercises"

        Exercise id ->
            "/exercises/" ++ String.fromInt id

        Attempts id ->
            "/results/" ++ String.fromInt id



-- PRIVATE


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Exercises Parser.top
        , Parser.map Exercises (Parser.s "")
        , Parser.map Exercise (Parser.s "exercises" </> Parser.int)
        , Parser.map Exercises (Parser.s "exercises")
        , Parser.map Attempts (Parser.s "results" </> Parser.int)
        ]
