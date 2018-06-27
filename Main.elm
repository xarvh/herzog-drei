module Main exposing (..)

import App
import Browser
import Dict exposing (Dict)


stringToTuple : String -> Maybe ( String, String )
stringToTuple str =
    case String.split "=" str of
        key :: values ->
            Just ( key, String.join "=" values )

        _ ->
            Nothing


view : App.Model -> Browser.Document App.Msg
view model =
    { title = "Herzog Drei"
    , body = [ App.view model ]
    }


main =
    Browser.document
        --(always App.Noop)
        { view = view
        , subscriptions = App.subscriptions
        , update = App.update
        , init = App.init
        }
