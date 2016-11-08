module Model exposing (Model, initialModel)

import Exercise exposing (Exercise)
import Hop.Types as Hop
import Route exposing (Route)
import Stopwatch exposing (Stopwatch)


type alias Model =
    { baseUrl : String
    , exercise : Maybe Exercise
    , exercises : List Exercise
    , stopwatch : Stopwatch
    , route : Route
    , address : Hop.Address
    }


initialModel : ( Route, Hop.Address ) -> Model
initialModel ( route, address ) =
    { baseUrl = "http://localhost:5000"
    , exercise = Nothing
    , exercises = []
    , stopwatch = Stopwatch.init
    , route = route
    , address = address
    }
