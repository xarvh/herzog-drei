module Unit exposing (..)

import Game exposing (..)


-- Subs constants


subReloadTime =
    4.0


subShootRange =
    7.0


subShootDamage =
    11



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
  if game.phase == PhaseSetup then
    unit
  else
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


toMech : Unit -> Maybe ( Unit, MechComponent )
toMech unit =
    case unit.component of
        UnitMech mech ->
            Just ( unit, mech )

        _ ->
            Nothing


findMech : String -> List Unit -> Maybe ( Unit, MechComponent )
findMech inputKey units =
    case units of
        [] ->
            Nothing

        u :: us ->
            case u.component of
                UnitMech mech ->
                    if mech.inputKey == inputKey then
                        Just ( u, mech )
                    else
                        findMech inputKey us

                _ ->
                    findMech inputKey us


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
