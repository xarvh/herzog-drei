module Mech exposing (..)

import Game exposing (..)
import Random


boolToClass : Bool -> MechClass
boolToClass bool =
    if bool then
        Heli
    else
        Plane


classGenerator : Random.Generator MechClass
classGenerator =
    Random.map boolToClass Random.bool
