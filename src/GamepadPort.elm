port module GamepadPort exposing (..)

import Gamepad


port gamepad : (Gamepad.Blob -> msg) -> Sub msg
