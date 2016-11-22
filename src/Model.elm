module Model exposing (Model, initialModel)

import Attempt exposing (Attempt)
import Exercise exposing (Exercise)
import Navigation
import Route exposing (Route)
import Stopwatch exposing (Stopwatch)
import UrlParser


type alias Model =
    { baseUrl : String
    , exercise : Maybe Exercise
    , exercises : List Exercise
    , stopwatch : Stopwatch
    , attempts : List Attempt
    , route : Maybe Route
    , location : Navigation.Location
    }


initialModel : Navigation.Location -> Model
initialModel location =
    { baseUrl = "http://localhost:5000"
    , exercise = Nothing
    , exercises = []
    , stopwatch = Stopwatch.init
    , attempts = []
    , route = UrlParser.parsePath Route.route location
    , location = location
    }
