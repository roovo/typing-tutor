module Model exposing (Model)

import Attempt exposing (Attempt)
import Exercise exposing (Exercise)
import Route exposing (Route)
import Stopwatch exposing (Stopwatch)
import Url.Parser


type alias Model =
    { baseUrl : String
    , exercise : Maybe Exercise
    , exercises : List Exercise
    , stopwatch : Stopwatch
    , attempts : List Attempt
    , route : Maybe Route
    }


-- initialModel : Navigation.Location -> Model
-- initialModel location =
--     { baseUrl = "http://localhost:5000"
--     , exercise = Nothing
--     , exercises = []
--     , stopwatch = Stopwatch.init
--     , attempts = []
--     , route = Url.Parser.parsePath Route.route location
--     }
