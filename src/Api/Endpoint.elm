module Api.Endpoint exposing
    ( Endpoint
    , attempts
    , exercise
    , exercises
    , request
    )

import Http
import Url.Builder as Builder exposing (QueryParameter, string)



-- TYPES


type Endpoint
    = Endpoint String



-- HTTP


request :
    { body : Http.Body
    , expect : Http.Expect a
    , headers : List Http.Header
    , method : String
    , timeout : Maybe Float
    , url : Endpoint
    , tracker : Maybe String
    }
    -> Cmd a
request config =
    Http.request
        { body = config.body
        , expect = config.expect
        , headers = config.headers
        , method = config.method
        , timeout = config.timeout
        , url = unwrap config.url
        , tracker = config.tracker
        }



-- ATTEMPTS ENDPOINTS


attempts : String -> Int -> Endpoint
attempts apiRoot exerciseId =
    url apiRoot
        [ "attempts" ]
        [ string "exerciseId" (String.fromInt exerciseId)
        , string "_sort" "completedAt"
        , string "_order" "DESC"
        ]



-- EXERCISE ENDPOINTS


exercise : String -> Int -> Endpoint
exercise apiRoot id =
    url apiRoot [ "exercises", String.fromInt id ] []


exercises : String -> Endpoint
exercises apiRoot =
    url apiRoot [ "exercises" ] []



-- PRIVATE


unwrap : Endpoint -> String
unwrap (Endpoint str) =
    str


url : String -> List String -> List QueryParameter -> Endpoint
url apiRoot pathElements queryParams =
    Builder.crossOrigin apiRoot pathElements queryParams
        |> Endpoint
