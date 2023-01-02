module Page.Error exposing (view)

import Html exposing (Html)


view : String -> { title : String, content : Html msg }
view message =
    { title = "Error"
    , content = Html.text ("Error loading " ++ message ++ ".")
    }
