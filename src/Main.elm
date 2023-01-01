module Main exposing (..)

import Attempt exposing (Attempt)
import Browser exposing (Document)
import Browser.Events exposing (onAnimationFrame)
import Browser.Navigation as Nav
import Exercise exposing (Exercise)
import Html exposing (Html)
import Http
import Json.Decode as Decode
import Page.Exercises
import Ports
import Route exposing (Route)
import Session exposing (Session)
import Stopwatch
import Time exposing (Posix)
import Url exposing (Url)


main : Program Decode.Value Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        , subscriptions = subscriptions
        , view = view
        }


init : Decode.Value -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    changeRouteTo (Route.fromUrl url)
        (Redirect (Session.init navKey))



-- MODEL


type Model
    = Exercises Page.Exercises.Model
    | NotFound Session
    | Redirect Session


toSession : Model -> Session
toSession model =
    case model of
        Exercises m ->
            Page.Exercises.toSession m

        NotFound session ->
            session

        Redirect session ->
            session



-- urlUpdate : Navigation.Location -> Model -> ( Model, Cmd Msg )
-- urlUpdate location model =
--     let
--         _ =
--             Debug.log "urlUpdate" location
--
--         newModel =
--             { model
--                 | route = UrlParser.parsePath Route.route location
--             }
--     in
--     ( newModel
--     , cmdForModelRoute newModel
--     )


cmdForModelRoute : Model -> Cmd Msg
cmdForModelRoute model =
    -- case model.route of
    --     Just ExercisesRoute ->
    --         Api.fetchExercises model GotExercises
    --     Just (ExerciseRoute id) ->
    --         Api.fetchExercise model id GotExercise
    --     Just (ResultRoute exerciseId) ->
    --         Api.fetchAttempts model exerciseId GotAttempts
    --     Nothing ->
    Cmd.none



-- UPDATE


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | GotExercisesMsg Page.Exercises.Msg



-- | CreatedAttempt (Result Http.Error Attempt)
-- | GotAttempts (Result Http.Error (List Attempt))
-- | GotExercise (Result Http.Error Exercise)
-- | GotTime Posix
-- | KeyDown KeyCode
-- | KeyPress KeyCode
-- | Tick Float


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( logWithoutTick msg, model ) of
        ( ChangedUrl _, _ ) ->
            ( model, Cmd.none )

        -- UrlChange location ->
        --     UrlUpdate.urlUpdate location model
        ( ClickedLink _, _ ) ->
            ( model, Cmd.none )

        ( GotExercisesMsg subMsg, Exercises subModel ) ->
            Page.Exercises.update subMsg subModel
                |> updateWith Exercises GotExercisesMsg

        ( GotExercisesMsg subMsg, subModel ) ->
            ( model, Cmd.none )



-- KeyPress keyCode ->
--     consumeChar keyCode model
-- KeyDown keyCode ->
--     consumeChar keyCode model
-- Tick elapsed ->
--     -- ( { model | stopwatch = Stopwatch.tick elapsed model.stopwatch }
--     ( model
--     , Cmd.none
--     )
-- GotTime timeNow ->
--     -- case model.exercise of
--     --     Nothing ->
--     --         ( model, Cmd.none )
--     --     Just exercise ->
--     --         ( model
--     --         , Cmd.none
--     --           -- , Api.createAttempt model (Attempt.init timeNow exercise) CreatedAttempt
--     --         )
--     ( model, Cmd.none )
-- GotExercises (Result.Ok exercises) ->
--     -- ( { model
--     --     | exercises = exercises
--     --     , exercise = Nothing
--     --     , attempts = []
--     --   }
--     -- , Cmd.none
--     -- )
--     ( model, Cmd.none )
-- GotExercise (Result.Ok exercise) ->
--     -- ( { model
--     --     | exercise = Just exercise
--     --     , stopwatch = Stopwatch.reset model.stopwatch
--     --     , exercises = []
--     --     , attempts = []
--     --   }
--     -- , Cmd.none
--     -- )
--     ( model, Cmd.none )
-- GotExercise (Result.Err _) ->
--     ( model, Cmd.none )
-- CreatedAttempt _ ->
--     ( model, Cmd.none )
-- GotAttempts (Result.Ok attempts) ->
--     -- ( { model
--     --     | attempts = attempts
--     --     , exercises = []
--     --     , exercise = Nothing
--     --   }
--     -- , Cmd.none
--     --   -- , Ports.showChart attempts
--     -- )
--     ( model, Cmd.none )
-- GotAttempts (Result.Err _) ->
--     ( model, Cmd.none )


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let
        session =
            toSession model
    in
    case maybeRoute of
        Nothing ->
            ( NotFound session, Cmd.none )

        Just Route.Exercises ->
            Page.Exercises.init session
                |> updateWith Exercises GotExercisesMsg


logWithoutTick : Msg -> Msg
logWithoutTick msg =
    case msg of
        -- Tick time ->
        --     msg
        _ ->
            Debug.log "msg" msg


updateWith :
    (subModel -> Model)
    -> (subMsg -> Msg)
    -> ( subModel, Cmd subMsg )
    -> ( Model, Cmd Msg )
updateWith toModel toMsg ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    -- case model.exercise of
    --     Just exercise ->
    --         if Exercise.isRunning exercise then
    --             Sub.batch <|
    --                 onAnimationFrame Tick
    --                     :: keyboardListeners
    --         else
    --             Sub.batch keyboardListeners
    --     Nothing ->
    Sub.none


keyboardListeners : List (Sub Msg)
keyboardListeners =
    -- [ Ports.keyDown KeyDown
    -- , Ports.keyPress KeyPress
    -- ]
    []



-- VIEW


view : Model -> Document Msg
view model =
    -- Html.div
    --     []
    --     [ body model ]
    { title = "foo"
    , body = [ Html.text "Hi there" ]
    }


body : Model -> Html Msg
body model =
    -- case model.route of
    --     Just ExercisesRoute ->
    --         View.Exercises.List.view model
    --     Just (ExerciseRoute id) ->
    --         View.Exercises.Run.view model
    --     Just (ResultRoute id) ->
    --         View.Exercises.Result.view model
    --     Nothing ->
    Html.text "Sorry - not round these parts - 404"
