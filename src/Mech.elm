module Mech exposing (..)

import Game exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Random
import Stats


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


heliSalvoPositions : Seconds -> Unit -> List Vec2
heliSalvoPositions stretchTime unit =
    let
        maxRange =
            20

        minimumSpacing =
            0.5

        maximumSpacing =
            maxRange / Stats.heli.salvoSize

        spacing =
            minimumSpacing + (maximumSpacing - minimumSpacing) * (stretchTime / Stats.heli.maxStretchTime)

        distanceFromMech =
            2

        direction =
            angleToVector unit.lookAngle

        indexToVec index =
            Vec2.add unit.position (Vec2.scale (distanceFromMech + spacing * toFloat index) direction)
    in
    List.range 1 Stats.heli.salvoSize |> List.map indexToVec


reloadTime : MechComponent -> Seconds
reloadTime mech =
    case mech.class of
        Blimp ->
            Stats.blimp.reload

        Heli ->
            case transformMode mech of
                ToMech ->
                    Stats.heli.walkReload

                ToFlyer ->
                    Stats.heli.flyReload

        Plane ->
            case transformMode mech of
                ToMech ->
                    Stats.plane.walkReload

                ToFlyer ->
                    Stats.plane.flyReload



-- Mech mechanics


transformMode : MechComponent -> TransformMode
transformMode mech =
    case mech.transformingTo of
        ToMech ->
            if mech.transformState < 1 then
                ToMech
            else
                ToFlyer

        ToFlyer ->
            if mech.transformState > 0 then
                ToFlyer
            else
                ToMech
