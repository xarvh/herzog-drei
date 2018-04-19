module Unit exposing (..)

import Game exposing (..)


-- Subs constants


subReloadTime =
    5.0


subShootRange =
    7.0


subShootDamage =
    8



-- Mech constants


mechShootRange =
    8.0


mechShootDamage =
    4


mechReloadTime mech =
    case transformMode mech of
        ToMech ->
            0.1

        ToPlane ->
            0.15



-- Mech mechanics


transformMode : MechComponent -> TransformMode
transformMode mech =
    case mech.transformingTo of
        ToMech ->
            if mech.transformState < 1 then
                ToMech
            else
                ToPlane

        ToPlane ->
            if mech.transformState > 0 then
                ToPlane
            else
                ToMech



-- Damage


takeDamage : Int -> Game -> Unit -> Unit
takeDamage rawDamage game unit =
    let
        ( healthPoints, armor ) =
            case unit.component of
                UnitMech _ ->
                    ( 160, 2 )

                UnitSub sub ->
                    case sub.mode of
                        UnitModeFree ->
                            ( 40, 0 )

                        UnitModeBase baseId ->
                            ( 70, 1 )

        damage =
            toFloat (rawDamage - armor) / healthPoints |> max 0
    in
    { unit | integrity = unit.integrity - damage }



-- Utilities


isMech : Unit -> Bool
isMech unit =
    case unit.component of
        UnitMech _ ->
            True

        _ ->
            False


isSub : Unit -> Bool
isSub unit =
    case unit.component of
        UnitSub _ ->
            True

        _ ->
            False
