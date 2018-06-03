module Main exposing (..)

import App
import Dict exposing (Dict)
import Navigation


stringToTuple : String -> Maybe ( String, String )
stringToTuple str =
    case String.split "=" str of
        key :: values ->
            Just ( key, String.join "=" values )

        _ ->
            Nothing


init : App.Flags -> Navigation.Location -> ( App.Model, Cmd App.Msg )
init flags location =
    let
        params =
            location.hash
                |> String.dropLeft 1
                |> String.split "&"
                |> List.filterMap stringToTuple
                |> Dict.fromList
    in
    App.init params flags


main =
    Navigation.programWithFlags
        (always App.Noop)
        { view = App.view
        , subscriptions = App.subscriptions
        , update = App.update
        , init = init
        }
