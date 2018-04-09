module PlayerThink exposing (..)

import Dict exposing (Dict)
import Game
    exposing
        ( Delta(..)
        , Game
        , Id
        , Player
        , PlayerInput
        , Seconds
        , TransformMode(..)
        , Unit
        , UnitType(..)
        , UnitTypeMechRecord
        , clampToRadius
        , tile2Vec
        , vec2Tile
        , vecToAngle
        )
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Set exposing (Set)
import View.Gfx
import View.Mech


-- globals


transformTime : Float
transformTime =
    0.2


mechFireInterval =
    0.1



--


transformMode : UnitTypeMechRecord -> TransformMode
transformMode mechRecord =
    case mechRecord.transformingTo of
        ToMech ->
            if mechRecord.transformState < 1 then
                ToMech
            else
                ToPlane

        ToPlane ->
            if mechRecord.transformState > 0 then
                ToPlane
            else
                ToMech



--


findMech : Id -> List Unit -> Maybe ( Unit, UnitTypeMechRecord )
findMech playerId units =
    case units of
        [] ->
            Nothing

        u :: us ->
            if u.ownerId /= playerId then
                findMech playerId us
            else
                case u.type_ of
                    UnitTypeMech mechRecord ->
                        Just ( u, mechRecord )

                    _ ->
                        findMech playerId us


think : PlayerInput -> Seconds -> Game -> Player -> Delta
think input dt game player =
    case game.unitById |> Dict.values |> findMech player.id of
        Nothing ->
            DeltaList []

        Just ( unit, mechRecord ) ->
            mechThink input dt game unit mechRecord


mechThink : PlayerInput -> Float -> Game -> Unit -> UnitTypeMechRecord -> Delta
mechThink input dt game unit mechRecord =
    let
        speed =
            case transformMode mechRecord of
                ToMech ->
                    2.0

                ToPlane ->
                    6.0

        dx =
            input.move
                |> clampToRadius 1
                |> Vec2.scale (speed * dt)

        hasFreeGround u =
            Set.member (vec2Tile u.position) game.staticObstacles |> not

        transformingTo =
            if input.transform && hasFreeGround unit then
                case mechRecord.transformingTo of
                    ToPlane ->
                        if mechRecord.transformState == 1 then
                            ToMech
                        else
                            mechRecord.transformingTo

                    ToMech ->
                        if mechRecord.transformState == 0 then
                            ToPlane
                        else
                            mechRecord.transformingTo
            else
                mechRecord.transformingTo

        transformDirection =
            case transformingTo of
                ToMech ->
                    (-)

                ToPlane ->
                    (+)

        transform =
            (\mechRecord ->
                { mechRecord
                    | transformingTo = transformingTo
                    , transformState = clamp 0 1 (transformDirection mechRecord.transformState (dt / transformTime))
                }
            )
                |> Game.updateUnitMechRecord
                |> DeltaUnit unit.id

        moveTarget =
            if input.rally then
                DeltaPlayer unit.ownerId (\g u -> { u | markerPosition = unit.position })
            else
                DeltaList []

        deltaMoveOrWalk =
            case transformMode mechRecord of
                ToMech ->
                    deltaWalk

                ToPlane ->
                    deltaFly

        moveMech =
            DeltaUnit unit.id (deltaMoveOrWalk dx)

        reload =
            if unit.timeToReload > 0 then
                DeltaUnit unit.id (\g u -> { u | timeToReload = max 0 (u.timeToReload - dt) })
            else
                DeltaList []

        aimAngle =
            Game.vecToAngle input.aim

        aim =
            (\g u ->
                { u
                    | lookAngle = Game.turnTo (5 * pi * dt) aimAngle u.lookAngle
                    , fireAngle = Game.turnTo (2 * pi * dt) aimAngle u.fireAngle
                }
            )
                |> DeltaUnit unit.id

        leftOrigin =
            View.Mech.leftGunOffset mechRecord.transformState unit.fireAngle |> Vec2.add unit.position

        rightOrigin =
            View.Mech.rightGunOffset mechRecord.transformState unit.fireAngle |> Vec2.add unit.position

        deltaFire origin =
            Game.deltaAddProjectile { id = -1, ownerId = unit.ownerId, position = origin, angle = aimAngle }

        fire =
            if input.fire && unit.timeToReload == 0 then
                DeltaList
                    [ DeltaUnit unit.id (\g u -> { u | timeToReload = mechFireInterval })
                    , deltaFire leftOrigin
                    , View.Gfx.deltaAddProjectileCase leftOrigin (aimAngle - pi - pi / 12)
                    , deltaFire rightOrigin
                    , View.Gfx.deltaAddProjectileCase rightOrigin (aimAngle + pi / 12)
                    ]
            else
                DeltaList []
    in
    DeltaList
        [ moveTarget
        , moveMech
        , reload
        , aim
        , fire
        , transform
        ]


deltaFly : Vec2 -> Game -> Unit -> Unit
deltaFly dp game unit =
    { unit | position = Vec2.add unit.position dp }


deltaWalk : Vec2 -> Game -> Unit -> Unit
deltaWalk dp game unit =
    let
        isObstacle tile =
            Set.member tile game.staticObstacles

        originalPosition =
            unit.position

        originalTile =
            vec2Tile originalPosition

        idealPosition =
            Vec2.add originalPosition dp

        idealTile =
            vec2Tile idealPosition

        didNotChangeTile =
            idealTile == originalTile

        idealPositionIsObstacle =
            isObstacle idealTile
    in
    if didNotChangeTile || not idealPositionIsObstacle then
        { unit | position = idealPosition }
    else
        let
            ( tX, tY ) =
                originalTile

            leftTile =
                ( tX - 1, tY )

            rightTile =
                ( tX + 1, tY )

            topTile =
                ( tX, tY + 1 )

            bottomTile =
                ( tX, tY - 1 )

            oX =
                toFloat tX

            oY =
                toFloat tY

            minX =
                if isObstacle leftTile then
                    oX
                else
                    oX - 1

            maxX =
                if isObstacle rightTile then
                    oX + 0.99
                else
                    oX + 1.99

            minY =
                if isObstacle bottomTile then
                    oY
                else
                    oY - 1

            maxY =
                if isObstacle topTile then
                    oY + 0.99
                else
                    oY + 1.99

            ( iX, iY ) =
                Vec2.toTuple idealPosition

            fX =
                clamp minX maxX iX

            fY =
                clamp minY maxY iY
        in
        { unit | position = vec2 fX fY }
