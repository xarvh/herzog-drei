module Unit exposing (..)

import Game exposing (..)


-- Subs constants


subReloadTime : SubComponent -> Seconds
subReloadTime sub =
    if sub.isBig then
        0.8
    else
        4.0


subShootRange : SubComponent -> Float
subShootRange sub =
    if sub.isBig then
        8.0
    else
        7.0


subShootDamage : SubComponent -> number
subShootDamage sub =
    if sub.isBig then
        4
    else
        11



-- Mech constants


mechShootRange =
    8.0


mechShootDamage =
    4


blimpBeamDamage =
    40


mechReloadTime mech =
    case mech.class of
        Blimp ->
          1.0

        _ ->
            case transformMode mech of
                ToMech ->
                    0.05

                ToFlyer ->
                    0.075



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



-- Damage


hitPointsAndArmor : Unit -> ( Float, Int )
hitPointsAndArmor unit =
    case unit.component of
        UnitMech mech ->
          case mech.class of
            Blimp ->
              ( 280, 0 )
            _ ->
              ( 160, 2 )


        UnitSub sub ->
            case sub.mode of
                UnitModeFree ->
                    if sub.isBig then
                        ( 160, 0 )
                    else
                        ( 40, 0 )

                UnitModeBase baseId ->
                    ( 70, 2 )


removeIntegrity : Float -> Game -> Unit -> Unit
removeIntegrity integrityLoss game unit =
    case game.mode of
        GameModeTeamSelection _ ->
            unit

        _ ->
            { unit | integrity = unit.integrity - integrityLoss }


takePiercingDamage : Float -> Game -> Unit -> Unit
takePiercingDamage rawDamage game unit =
    let
        ( healthPoints, armor ) =
            hitPointsAndArmor unit

        damage =
            rawDamage / healthPoints |> max 0
    in
    removeIntegrity damage game unit


takeDamage : Int -> Game -> Unit -> Unit
takeDamage rawDamage game unit =
    let
        ( healthPoints, armor ) =
            hitPointsAndArmor unit

        damage =
            toFloat (rawDamage - armor) / healthPoints |> max 0
    in
    removeIntegrity damage game unit



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
