port module GamepadPort exposing (..)

import Gamepad


port gamepad : (( Float, Gamepad.Blob ) -> msg) -> Sub msg
