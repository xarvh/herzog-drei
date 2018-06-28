module Gamepad.Private exposing (..)

import Array exposing (Array)


type alias Blob =
    List BlobFrame


type alias BlobFrame =
    { gamepads : List GamepadFrame
    , timestamp : Float
    }


type alias GamepadFrame =
    { axes : Array Float
    , buttons : Array ( Bool, Float )
    , id : String
    , index : Int
    , mapping : String
    , timestamp : Float
    }
