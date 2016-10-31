module Event exposing (Event)


type alias Event =
    { expected : String
    , actual : String
    , timeTaken : Int
    }
