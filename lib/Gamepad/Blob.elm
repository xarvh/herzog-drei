module Gamepad.Blob exposing (..)

import Array exposing (Array)


type alias Blob =
    ( BlobFrame, BlobFrame )


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
    }


emptyBlobFrame : BlobFrame
emptyBlobFrame =
    { timestamp = 0
    , gamepads = []
    }


emptyBlob : Blob
emptyBlob =
    ( emptyBlobFrame, emptyBlobFrame )
