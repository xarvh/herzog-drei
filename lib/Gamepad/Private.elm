module Gamepad.Private exposing (..)

import Array exposing (Array)


type alias Blob =
    List Frame


type alias Frame =
    { gamepads : List (Maybe RawGamepad)
    , timestamp : Float
    }


type alias RawGamepad =
    { axes : Array Float
    , buttons : Array ( Bool, Float )
    , connected : Bool
    , id : String
    , index : Int
    , mapping : String
    , timestamp : Float
    }
