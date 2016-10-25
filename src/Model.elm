module Model exposing (Model, initialModel)

import Exercise exposing (Exercise)
import ExampleExercise
import Hop.Types as Hop
import Msg exposing (Msg)
import Routes exposing (Route)
import Stopwatch exposing (Stopwatch)


type alias Model =
    { baseUrl : String
    , exercise : Exercise
    , stopwatch : Stopwatch
    , route : Route
    , address : Hop.Address
    }


initialModel : ( Route, Hop.Address ) -> Model
initialModel ( route, address ) =
    { baseUrl =
        "http://localhost:5000"
        -- , exercise = (Debug.log "init.exercise" (Exercise.init 1 "elm" ExampleExercise.elm))
    , exercise = Exercise.init 1 "elm" ExampleExercise.elm
    , stopwatch = Stopwatch.init
    , route = route
    , address = address
    }
