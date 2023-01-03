module Api exposing
    ( getMany
    , getOne
    , post
    )

import Api.Endpoint as Endpoint exposing (Endpoint)
import Http


getOne : Endpoint -> Http.Expect a -> Cmd a
getOne url expect =
    Endpoint.request
        { method = "GET"
        , url = url
        , expect = expect
        , headers = [ Http.header "Accept" "application/vnd.pgrst.object+json" ]
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        }


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


post : Endpoint -> Http.Body -> Http.Expect a -> Cmd a
post url body expect =
    Endpoint.request
        { method = "POST"
        , url = url
        , expect = expect
        , headers = []
        , body = body
        , timeout = Nothing
        , tracker = Nothing
        }
