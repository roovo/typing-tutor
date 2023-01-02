module Page.NotFound exposing (view)

import Html exposing (Html)


view : { title : String, content : Html msg }
view =
    { title = "Not FOund"
    , content = Html.text "Sorry, I can't find the page you seem to be looking for :("
    }
