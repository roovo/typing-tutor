module Session exposing
    ( Config
    , Session
    , apiRoot
    , init
    , mapConfig
    , navKey
    , stopwatch
    )

import Browser.Navigation as Nav
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



-- TRANSFORM


mapConfig : (Config -> Config) -> Session -> Session
mapConfig func (Session key conf) =
    Session key (func conf)



-- PRIVATE


config : Session -> Config
config (Session _ c) =
    c
