module Main exposing (..)

import Html exposing (Html)
import Html.App


main =
    Html.App.program
        { init = init
        , subscriptions = (\_ -> Sub.none)
        , update = update
        , view = view
        }



-- MODEL


type alias Model =
    { text : String
    }


init : ( Model, Cmd Msg )
init =
    ( { text = "Something to type"
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = NothingYet


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.text model.text ]
