port module GamepadPort exposing (..)

import Gamepad
import Time exposing (Time)


port gamepad : (( Time, Gamepad.Blob ) -> msg) -> Sub msg
