module Unit exposing (..)

import ColorPattern exposing (ColorPattern)
import Dict exposing (Dict)
import Game exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Stats


-- Damage


hitPointsAndArmor : Unit -> ( Float, Float )
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
            { unit
                | integrity = unit.integrity - integrityLoss
                , lastDamaged = game.time
            }


takePiercingDamage : Float -> Game -> Unit -> Unit
takePiercingDamage rawDamage game unit =
    let
        ( healthPoints, armor ) =
            hitPointsAndArmor unit

        damage =
            rawDamage / healthPoints |> max 0
    in
    removeIntegrity damage game unit


takeDamage : Float -> Game -> Unit -> Unit
takeDamage rawDamage game unit =
    let
        ( healthPoints, armor ) =
            hitPointsAndArmor unit

        damage =
            (rawDamage - armor) / healthPoints |> max 0
    in
    removeIntegrity damage game unit


splashDamage : Game -> Maybe TeamId -> Vec2 -> Float -> Float -> Delta
splashDamage game maybeTeamId position damage radius =
    game.unitById
        |> Dict.values
        |> List.filter (\u -> u.maybeTeamId /= maybeTeamId && Vec2.distanceSquared u.position position < radius)
        |> List.map (\u -> deltaUnit u.id (takeDamage damage))
        |> deltaList



-- Utilities


filterAndMapAll : Game -> (Unit -> Bool) -> (Unit -> a) -> List a
filterAndMapAll game test map =
    let
        testUnit id unit list =
            if test unit then
                map unit :: list
            else
                list
    in
    Dict.foldl testUnit [] game.unitById


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


colorPattern : Game -> Unit -> ColorPattern
colorPattern game unit =
    teamColorPattern game unit.maybeTeamId
