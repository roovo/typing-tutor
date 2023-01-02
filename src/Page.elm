module Page exposing (Page(..), view)

import Browser exposing (Document)
import Html exposing (Html)
import Html.Attributes
import Route
import Session exposing (Session)


type Page
    = Exercises
    | Other


view : Session -> { title : String, content : Html msg } -> Document msg
view session { title, content } =
    { title = title ++ " - Typing Tutor"
    , body = [ content ]
    }
