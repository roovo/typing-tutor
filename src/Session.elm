module Session exposing
    ( Session
    , apiRoot
    , init
    , navKey
    , stopwatch
    )

import Attempt exposing (Attempt)
import Browser.Navigation as Nav
import Exercise exposing (Exercise)
import Route exposing (Route)
import Stopwatch exposing (Stopwatch)



-- MODEL


type Session
    = Session Nav.Key Config


type alias Config =
    { apiRoot : String
    , stopwatch : Stopwatch
    }


init : Nav.Key -> Session
init key =
    Session key
        { apiRoot = "http://localhost:5000"
        , stopwatch = Stopwatch.init
        }



-- INFO


apiRoot : Session -> String
apiRoot =
    .apiRoot << config


navKey : Session -> Nav.Key
navKey (Session n _) =
    n


stopwatch : Session -> Stopwatch
stopwatch =
    .stopwatch << config



-- PRIVATE


config : Session -> Config
config (Session _ c) =
    c
