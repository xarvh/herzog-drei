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


init : App.Flags -> ( App.Model, Cmd App.Msg )
init flags =
    let
        params =
            Dict.empty

        {-
           location.hash
               |> String.dropLeft 1
               |> String.split "&"
               |> List.filterMap stringToTuple
               |> Dict.fromList
        -}
    in
    App.init params flags


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
        , init = init
        }
