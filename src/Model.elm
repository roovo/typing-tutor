module Model exposing (Model, init)

import Exercise exposing (Exercise)
import ExampleExercise
import Hop.Types as Hop
import Msg exposing (Msg)
import Routes exposing (Route)
import Stopwatch exposing (Stopwatch)


type alias Model =
    { exercise : Exercise
    , stopwatch : Stopwatch
    , route : Route
    , address : Hop.Address
    }


init : ( Route, Hop.Address ) -> ( Model, Cmd Msg )
init ( route, address ) =
    let
        _ =
            Debug.log "init" ( route, address )
    in
        ( { exercise = (Debug.log "init.exercise" (Exercise.init ExampleExercise.elm))
          , stopwatch = Stopwatch.init
          , route = route
          , address = address
          }
        , Cmd.none
        )
