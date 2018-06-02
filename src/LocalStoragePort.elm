port module LocalStoragePort exposing (set)


port localStorageSet : { key : String, value : String } -> Cmd msg


set : String -> String -> Cmd msg
set key value =
    localStorageSet { key = key, value = value }
