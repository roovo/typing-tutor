module Session exposing
    ( Session
    , fromNavKey
    )

import Attempt exposing (Attempt)
import Browser.Navigation as Nav
import Exercise exposing (Exercise)
import Route exposing (Route)
import Stopwatch exposing (Stopwatch)


type Session
    = Session Nav.Key Config


type alias Config =
    { baseUrl : String
    , exercise : Maybe Exercise
    , exercises : List Exercise
    , stopwatch : Stopwatch
    , attempts : List Attempt
    , route : Maybe Route
    }


fromNavKey : Nav.Key -> Session
fromNavKey key =
    Session key
        { baseUrl = "http://localhost:5000"
        , exercise = Nothing
        , exercises = []
        , stopwatch = Stopwatch.init
        , attempts = []

        -- , route = Url.Parser.parsePath Route.route location
        , route = Nothing
        }
