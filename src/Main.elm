module Main exposing (..)

import Browser exposing (Document)
import Browser.Events exposing (onAnimationFrame)
import Browser.Navigation as Nav
import Exercise
import Html exposing (Html)
import Json.Decode as Decode
import Msg exposing (Msg(..))
import Ports
import Route exposing (Route)
import Session exposing (Session)
import Stopwatch
import Url exposing (Url)


main : Program Decode.Value Model Msg
main =
    Browser.application
        { init = init
        , subscriptions = subscriptions
        , update = update
        , view = view
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        }


init : Decode.Value -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url navKey =
    changeRouteTo (Route.fromUrl url)
        (Redirect (Session.fromNavKey navKey))



-- MODEL


type Model
    = Redirect Session


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    ( model, Cmd.none )



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
    --     Just ExerciseListRoute ->
    --         Api.fetchExercises model GotExercises
    --     Just (ExerciseRoute id) ->
    --         Api.fetchExercise model id GotExercise
    --     Just (ResultRoute exerciseId) ->
    --         Api.fetchAttempts model exerciseId GotAttempts
    --     Nothing ->
    Cmd.none



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case logWithoutTick msg of
        -- KeyPress keyCode ->
        --     consumeChar keyCode model
        -- KeyDown keyCode ->
        --     consumeChar keyCode model
        Tick elapsed ->
            -- ( { model | stopwatch = Stopwatch.tick elapsed model.stopwatch }
            ( model
            , Cmd.none
            )

        ChangedUrl _ ->
            ( model, Cmd.none )

        ClickedLink _ ->
            ( model, Cmd.none )

        -- UrlChange location ->
        --     UrlUpdate.urlUpdate location model
        GotTime timeNow ->
            -- case model.exercise of
            --     Nothing ->
            --         ( model, Cmd.none )
            --     Just exercise ->
            --         ( model
            --         , Cmd.none
            --           -- , Api.createAttempt model (Attempt.init timeNow exercise) CreatedAttempt
            --         )
            ( model, Cmd.none )

        GotExercises (Result.Ok exercises) ->
            -- ( { model
            --     | exercises = exercises
            --     , exercise = Nothing
            --     , attempts = []
            --   }
            -- , Cmd.none
            -- )
            ( model, Cmd.none )

        GotExercises (Result.Err _) ->
            ( model, Cmd.none )

        GotExercise (Result.Ok exercise) ->
            -- ( { model
            --     | exercise = Just exercise
            --     , stopwatch = Stopwatch.reset model.stopwatch
            --     , exercises = []
            --     , attempts = []
            --   }
            -- , Cmd.none
            -- )
            ( model, Cmd.none )

        GotExercise (Result.Err _) ->
            ( model, Cmd.none )

        CreatedAttempt _ ->
            ( model, Cmd.none )

        GotAttempts (Result.Ok attempts) ->
            -- ( { model
            --     | attempts = attempts
            --     , exercises = []
            --     , exercise = Nothing
            --   }
            -- , Cmd.none
            --   -- , Ports.showChart attempts
            -- )
            ( model, Cmd.none )

        GotAttempts (Result.Err _) ->
            ( model, Cmd.none )


logWithoutTick : Msg -> Msg
logWithoutTick msg =
    case msg of
        Tick time ->
            msg

        _ ->
            Debug.log "msg" msg



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
    , body = []
    }


body : Model -> Html Msg
body model =
    -- case model.route of
    --     Just ExerciseListRoute ->
    --         View.Exercises.List.view model
    --     Just (ExerciseRoute id) ->
    --         View.Exercises.Run.view model
    --     Just (ResultRoute id) ->
    --         View.Exercises.Result.view model
    --     Nothing ->
    Html.text "Sorry - not round these parts - 404"
