module Page.Exercises exposing
    ( Model
    , Msg
    , Status
    , init
    , toSession
    , update
    , view
    )

import Api
import Api.Endpoint as Endpoint
import Exercise exposing (Exercise)
import Html exposing (Html)
import Html.Attributes as Attr
import Http
import Json.Decode as JD
import Page.Error
import Route
import Session exposing (Session)



-- MODEL


type alias Model =
    { session : Session
    , exercises : Status (List Exercise)
    }


type Status a
    = Loading
    | Loaded a
    | Failed


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session
      , exercises = Loading
      }
    , fetchExercises session
    )


toSession : Model -> Session
toSession =
    .session


fetchExercises : Session -> Cmd Msg
fetchExercises session =
    JD.list Exercise.decoder
        |> Http.expectJson CompletedExercisesFetch
        |> Api.getMany (Endpoint.exercises (Session.apiRoot session))



-- UPDATE


type Msg
    = CompletedExercisesFetch (Result Http.Error (List Exercise))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.exercises ) of
        ( CompletedExercisesFetch (Ok exercises), _ ) ->
            ( { model | exercises = Loaded exercises }, Cmd.none )

        ( CompletedExercisesFetch (Err _), _ ) ->
            ( { model | exercises = Failed }, Cmd.none )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    let
        pageTitle : String
        pageTitle =
            "Exercises"
    in
    case model.exercises of
        Loaded exercises ->
            { title = pageTitle
            , content = content exercises
            }

        Loading ->
            { title = pageTitle
            , content = Html.text ""
            }

        Failed ->
            Page.Error.view "exercises"


content : List Exercise -> Html Msg
content exercises =
    Html.div []
        [ Html.h2 [] [ Html.text "Available exercises" ]
        , Html.div []
            [ exercisesList exercises ]
        ]


exercisesList : List Exercise -> Html Msg
exercisesList exercises =
    Html.ul []
        (List.map exerciseItem exercises)


exerciseItem : Exercise -> Html Msg
exerciseItem exercise =
    Html.li []
        [ Html.a
            [ Attr.href (Route.urlFor (Route.Exercise exercise.id)) ]
            [ Html.text exercise.title ]
        , Html.text " ("
        , Html.a
            [ Attr.href (Route.urlFor (Route.Attempts exercise.id)) ]
            [ Html.text "results" ]
        , Html.text ")"
        ]
