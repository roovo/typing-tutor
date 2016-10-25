module Routes exposing (Route, urlParser)

import Navigation
import UrlParser
import Hop
import Hop.Types as Hop


hopConfig : Hop.Config
hopConfig =
    { hash = False
    , basePath = ""
    }


type Route
    = ExerciseListRoute
    | RunExerciseRoute
    | NotFoundRoute


routes : UrlParser.Parser (Route -> a) a
routes =
    UrlParser.oneOf
        [ UrlParser.format ExerciseListRoute (UrlParser.s "")
        , UrlParser.format RunExerciseRoute (UrlParser.s "run")
        ]


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
