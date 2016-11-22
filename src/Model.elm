module Model exposing (Model, initialModel)

import Attempt exposing (Attempt)
import Exercise exposing (Exercise)
import Route exposing (Route)
import Stopwatch exposing (Stopwatch)


type alias Model =
    { baseUrl : String
    , exercise : Maybe Exercise
    , exercises : List Exercise
    , stopwatch : Stopwatch
    , attempts : List Attempt
    , route : Route
    , address : Hop.Address
    }


initialModel : ( Route, Hop.Address ) -> Model
initialModel ( route, address ) =
    { baseUrl = "http://localhost:5000"
    , exercise = Nothing
    , exercises = []
    , stopwatch = Stopwatch.init
    , attempts = []
    , route = route
    , address = address
    }
