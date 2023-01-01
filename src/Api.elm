module Api exposing (getMany)

import Api.Endpoint as Endpoint exposing (Endpoint)
import Http


getMany : Endpoint -> Http.Expect a -> Cmd a
getMany url expect =
    Endpoint.request
        { method = "GET"
        , url = url
        , expect = expect
        , headers = []
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        }
