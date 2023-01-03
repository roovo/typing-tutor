module Page exposing (view)

import Browser exposing (Document)
import Html exposing (Html)


view : { title : String, content : Html msg } -> Document msg
view { title, content } =
    { title = title ++ " - Typing Tutor"
    , body = [ content ]
    }
