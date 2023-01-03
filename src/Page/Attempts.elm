module Page.Attempts exposing
    ( Model
    , Msg
    , init
    , toSession
    , update
    , view
    )

import Api
import Api.Endpoint as Endpoint
import Attempt exposing (Attempt)
import Browser.Events exposing (onAnimationFrameDelta)
import Event
import Html exposing (Html)
import Html.Attributes
import Http
import Json.Decode as JD
import Json.Encode as JE
import Page.Error
import Ports
import Round
import Route
import Session exposing (Session)
import Task
import Time exposing (Posix)



-- MODEL


type alias Model =
    { session : Session
    , attempts : Status (List Attempt)
    }


type Status a
    = Loading
    | LoadingSlowly
    | Loaded a
    | Failed


init : Session -> Int -> ( Model, Cmd Msg )
init session id =
    ( { session = session
      , attempts = Loading
      }
    , fetchAttempts session id
    )


toSession : Model -> Session
toSession =
    .session


fetchAttempts : Session -> Int -> Cmd Msg
fetchAttempts session id =
    JD.list Attempt.decoder
        |> Http.expectJson CompletedAttemptsFetch
        |> Api.getOne (Endpoint.attempts (Session.apiRoot session) id)



-- UPDATE


type Msg
    = CompletedAttemptsFetch (Result Http.Error (List Attempt))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.attempts ) of
        ( CompletedAttemptsFetch (Ok attempts), _ ) ->
            ( { model | attempts = Loaded attempts }, Cmd.none )

        ( CompletedAttemptsFetch (Err _), _ ) ->
            ( { model | attempts = Failed }, Cmd.none )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    let
        pageTitle =
            "Results"
    in
    case model.attempts of
        Loaded attempts ->
            { title = pageTitle
            , content = content attempts
            }

        Loading ->
            { title = pageTitle
            , content = Html.text ""
            }

        LoadingSlowly ->
            { title = pageTitle
            , content = Html.text "Loading..."
            }

        Failed ->
            Page.Error.view "results"


content : List Attempt -> Html Msg
content attempts =
    Html.div []
        [ Html.h2 [] [ Html.text "Results" ]
        , Html.div []
            [ attemptsList attempts ]
        ]


attemptsList : List Attempt -> Html Msg
attemptsList attmepts =
    Html.table []
        [ Html.thead []
            [ Html.tr []
                [ Html.th [] [ Html.text "Date" ]
                , Html.th [] [ Html.text "Accuracy" ]
                , Html.th [] [ Html.text "WPM" ]
                ]
            ]
        , Html.tbody []
            (List.map attmeptView attmepts)
        ]


attmeptView : Attempt -> Html Msg
attmeptView attempt =
    Html.tr []
        [ Html.td []
            [ Html.text <| timeString attempt.completedAt ]
        , Html.td []
            [ Html.text <| Round.round 2 attempt.accuracy ]
        , Html.td []
            [ Html.text <| Round.round 2 attempt.wpm ]
        ]


timeString : Posix -> String
timeString time =
    let
        day =
            String.fromInt <| Time.toDay Time.utc time

        month =
            case Time.toMonth Time.utc time of
                Time.Jan ->
                    "Janm"

                Time.Feb ->
                    "Feb"

                Time.Mar ->
                    "Mar"

                Time.Apr ->
                    "Apr"

                Time.May ->
                    "May"

                Time.Jun ->
                    "Jun"

                Time.Jul ->
                    "Jul"

                Time.Aug ->
                    "Aug"

                Time.Sep ->
                    "Sep"

                Time.Oct ->
                    "Oct"

                Time.Nov ->
                    "Nov"

                Time.Dec ->
                    "Dec"

        year =
            String.fromInt <| Time.toYear Time.utc time
    in
    day ++ " " ++ month ++ " " ++ year
