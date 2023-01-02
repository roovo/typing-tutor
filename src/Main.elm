module Main exposing (..)

import Attempt exposing (Attempt)
import Browser exposing (Document)
import Browser.Events exposing (onAnimationFrame)
import Browser.Navigation as Nav
import Exercise exposing (Exercise)
import Html exposing (Html)
import Http
import Json.Decode as Decode
import Page
import Page.Blank
import Page.Exercise
import Page.Exercises
import Page.NotFound
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
    = Exercise Page.Exercise.Model
    | Exercises Page.Exercises.Model
    | NotFound Session
    | Redirect Session


toSession : Model -> Session
toSession model =
    case model of
        Exercise m ->
            Page.Exercise.toSession m

        Exercises m ->
            Page.Exercises.toSession m

        NotFound session ->
            session

        Redirect session ->
            session



-- UPDATE


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | GotExercisesMsg Page.Exercises.Msg
    | GotExerciseMsg Page.Exercise.Msg
    | Ignored
    | KeyDown Int
    | KeyPress Int



-- | CreatedAttempt (Result Http.Error Attempt)
-- | GotAttempts (Result Http.Error (List Attempt))
-- | GotTime Posix
-- | Tick Float


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( logWithoutTick msg, model ) of
        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl (Session.navKey (toSession model))
                        (Url.toString url)
                    )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        ( GotExerciseMsg subMsg, Exercise subModel ) ->
            Page.Exercise.update subMsg subModel
                |> updateWith Exercise GotExerciseMsg

        ( GotExerciseMsg subMsg, subModel ) ->
            ( model, Cmd.none )

        ( GotExercisesMsg subMsg, Exercises subModel ) ->
            Page.Exercises.update subMsg subModel
                |> updateWith Exercises GotExercisesMsg

        ( GotExercisesMsg subMsg, subModel ) ->
            ( model, Cmd.none )

        ( Ignored, _ ) ->
            ( model, Cmd.none )

        ( KeyPress keyCode, _ ) ->
            -- consumeChar keyCode model
            ( model, Cmd.none )

        ( KeyDown keyCode, _ ) ->
            -- consumeChar keyCode model
            ( model, Cmd.none )



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

        Just (Route.Exercise id) ->
            Page.Exercise.init session id
                |> updateWith Exercise GotExerciseMsg

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
    case model of
        Exercise subModel ->
            viewPage model GotExerciseMsg (Page.Exercise.view subModel)

        Exercises subModel ->
            viewPage model GotExercisesMsg (Page.Exercises.view subModel)

        NotFound _ ->
            viewPage model (\_ -> Ignored) Page.NotFound.view

        Redirect _ ->
            viewPage model (\_ -> Ignored) Page.Blank.view


viewPage :
    Model
    -> (msg -> Msg)
    -> { title : String, content : Html msg }
    -> Document Msg
viewPage model toMsg pageView =
    let
        mappedView =
            { title = pageView.title
            , content = Html.map toMsg pageView.content
            }
    in
    Page.view
        (toSession model)
        mappedView
