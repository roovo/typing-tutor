module Route exposing (Route(..), route, urlFor)

import Navigation
import UrlParser exposing ((</>))


type Route
    = ExerciseListRoute
    | ExerciseRoute Int
    | ResultRoute Int


urlFor : Route -> String
urlFor route =
    case route of
        ExerciseListRoute ->
            "/exercises"

        ExerciseRoute id ->
            "/exercises/" ++ toString id

        ResultRoute id ->
            "/results/" ++ toString id


route : UrlParser.Parser (Route -> a) a
route =
    UrlParser.oneOf
        [ UrlParser.map ExerciseListRoute (UrlParser.s "")
        , UrlParser.map ExerciseRoute (UrlParser.s "exercises" </> UrlParser.int)
        , UrlParser.map ExerciseListRoute (UrlParser.s "exercises")
        , UrlParser.map ResultRoute (UrlParser.s "results" </> UrlParser.int)
        ]
