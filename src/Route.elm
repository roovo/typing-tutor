module Route exposing (Route(..), urlFor, urlParser)

import Navigation
import UrlParser exposing ((</>))
import Hop
import Hop.Types as Hop


hopConfig : Hop.Config
hopConfig =
    { hash = False
    , basePath = ""
    }


type Route
    = ExerciseListRoute
    | ExerciseRoute Int
    | RunExerciseRoute
    | NotFoundRoute


routes : UrlParser.Parser (Route -> a) a
routes =
    UrlParser.oneOf
        [ UrlParser.format ExerciseListRoute (UrlParser.s "")
        , UrlParser.format ExerciseRoute (UrlParser.s "exercises" </> UrlParser.int)
        , UrlParser.format ExerciseListRoute (UrlParser.s "exercises")
        , UrlParser.format RunExerciseRoute (UrlParser.s "run")
        ]


urlFor : Route -> String
urlFor route =
    case route of
        ExerciseListRoute ->
            "exercises"

        ExerciseRoute id ->
            "exercises/" ++ toString id

        RunExerciseRoute ->
            "exercises/1"

        NotFoundRoute ->
            "404"


urlParser : Navigation.Parser ( Route, Hop.Address )
urlParser =
    let
        parse path =
            path
                |> UrlParser.parse identity routes
                |> Result.withDefault NotFoundRoute

        resolver =
            Hop.makeResolver hopConfig parse
    in
        Navigation.makeParser (.href >> resolver)
