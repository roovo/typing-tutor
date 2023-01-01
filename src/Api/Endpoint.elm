module Api.Endpoint exposing
    ( Endpoint
    , exercises
    , request
    )

import Http
import Url.Builder as Builder exposing (QueryParameter)



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



-- EXERCISE ENDPOINTS


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
