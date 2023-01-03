module Main exposing (Model(..), Msg(..), main)

import Browser exposing (Document)
import Browser.Navigation as Nav
import Html exposing (Html)
import Json.Decode as Decode
import Page
import Page.Attempts
import Page.Blank
import Page.Exercise
import Page.Exercises
import Page.NotFound
import Route exposing (Route)
import Session exposing (Session)
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
init _ url navKey =
    changeRouteTo (Route.fromUrl url)
        (Redirect (Session.init navKey))



-- MODEL


type Model
    = Attempts Page.Attempts.Model
    | Exercise Page.Exercise.Model
    | Exercises Page.Exercises.Model
    | NotFound Session
    | Redirect Session


toSession : Model -> Session
toSession model =
    case model of
        Attempts m ->
            Page.Attempts.toSession m

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
    | GotAttemptsMsg Page.Attempts.Msg
    | GotExercisesMsg Page.Exercises.Msg
    | GotExerciseMsg Page.Exercise.Msg
    | Ignored


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
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

        ( GotAttemptsMsg subMsg, Attempts subModel ) ->
            Page.Attempts.update subMsg subModel
                |> updateWith Attempts GotAttemptsMsg

        ( GotAttemptsMsg _, _ ) ->
            ( model, Cmd.none )

        ( GotExerciseMsg subMsg, Exercise subModel ) ->
            Page.Exercise.update subMsg subModel
                |> updateWith Exercise GotExerciseMsg

        ( GotExerciseMsg _, _ ) ->
            ( model, Cmd.none )

        ( GotExercisesMsg subMsg, Exercises subModel ) ->
            Page.Exercises.update subMsg subModel
                |> updateWith Exercises GotExercisesMsg

        ( GotExercisesMsg _, _ ) ->
            ( model, Cmd.none )

        ( Ignored, _ ) ->
            ( model, Cmd.none )



-- CreatedAttempt _ ->
--     ( model, Cmd.none )


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let
        session : Session
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

        Just (Route.Attempts id) ->
            Page.Attempts.init session id
                |> updateWith Attempts GotAttemptsMsg


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
    case model of
        Exercise subModel ->
            Page.Exercise.subscriptions subModel
                |> Sub.map GotExerciseMsg

        _ ->
            Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    case model of
        Attempts subModel ->
            viewPage GotAttemptsMsg (Page.Attempts.view subModel)

        Exercise subModel ->
            viewPage GotExerciseMsg (Page.Exercise.view subModel)

        Exercises subModel ->
            viewPage GotExercisesMsg (Page.Exercises.view subModel)

        NotFound _ ->
            viewPage (\_ -> Ignored) Page.NotFound.view

        Redirect _ ->
            viewPage (\_ -> Ignored) Page.Blank.view


viewPage :
    (msg -> Msg)
    -> { title : String, content : Html msg }
    -> Document Msg
viewPage toMsg pageView =
    let
        mappedView : { title : String, content : Html Msg }
        mappedView =
            { title = pageView.title
            , content = Html.map toMsg pageView.content
            }
    in
    Page.view mappedView
