module Mech exposing (..)

import Game exposing (..)
import Random


intToClass : Int -> MechClass
intToClass n =
    case n of
        0 ->
            Plane

        1 ->
            Heli

        _ ->
            Blimp


classGenerator : Random.Generator MechClass
classGenerator =
    Random.map intToClass (Random.int 0 2)
