module Main exposing (..)

import Html exposing (Html)
import Html.App
import Script exposing (Script)


main =
    Html.App.program
        { init = init "Something to type"
        , subscriptions = (\_ -> Sub.none)
        , update = update
        , view = view
        }



-- MODEL


type alias Model =
    { script : Script
    }


init : String -> ( Model, Cmd Msg )
init toType =
    ( { script = Script.init toType
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
    Html.div
        []
        [ Html.code
            []
            [ Html.text ""
            ]
        , Html.hr [] []
        , Html.text <| toString model
        ]
