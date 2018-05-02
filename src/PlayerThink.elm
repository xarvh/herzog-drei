module PlayerThink exposing (..)

import Base
import ColorPattern
import Dict exposing (Dict)
import Game exposing (..)
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Pathfinding
import Set exposing (Set)
import Unit
import View.Gfx
import View.Mech


-- globals


transformTime : Float
transformTime =
    0.2



--


findMech : Id -> List Unit -> Maybe ( Unit, MechComponent )
findMech playerId units =
    case units of
        [] ->
            Nothing

        u :: us ->
            if u.ownerId /= playerId then
                findMech playerId us
            else
                case u.component of
                    UnitMech mech ->
                        Just ( u, mech )

                    _ ->
                        findMech playerId us


think : PlayerInput -> Seconds -> Game -> Player -> Delta
think input dt game player =
    case game.unitById |> Dict.values |> findMech player.id of
        Nothing ->
            moveViewportToBase dt game player

        Just ( unit, mech ) ->
            mechThink input dt game unit mech


moveViewportToBase : Seconds -> Game -> Player -> Delta
moveViewportToBase dt game player =
    case Base.playerMainBase game player.id of
        Nothing ->
            DeltaNone

        Just mainBase ->
            let
                dp =
                    Vec2.sub mainBase.position player.viewportPosition

                length =
                    Vec2.length dp

                direction =
                    Vec2.normalize dp

                speed =
                    30

                maxLength =
                    min (speed * dt) length

                maxDp =
                    Vec2.scale maxLength direction

                position =
                    Vec2.add player.viewportPosition maxDp
            in
            if length < 0.01 then
                DeltaNone
            else
                DeltaPlayer player.id (\g p -> { p | viewportPosition = position })


mechThink : PlayerInput -> Seconds -> Game -> Unit -> MechComponent -> Delta
mechThink input dt game unit mech =
    let
        speed =
            case Unit.transformMode mech of
                ToMech ->
                    5.0

                ToPlane ->
                    12.0

        dx =
            input.move
                |> clampToRadius 1
                |> Vec2.scale (speed * dt)

        hasFreeGround u =
            Set.member (vec2Tile u.position) game.staticObstacles |> not

        transformingTo =
            if input.transform && hasFreeGround unit then
                case mech.transformingTo of
                    ToPlane ->
                        if mech.transformState == 1 then
                            ToMech
                        else
                            mech.transformingTo

                    ToMech ->
                        if mech.transformState == 0 then
                            ToPlane
                        else
                            mech.transformingTo
            else
                mech.transformingTo

        transformDirection =
            case transformingTo of
                ToMech ->
                    (-)

                ToPlane ->
                    (+)

        transform =
            (\mech ->
                { mech
                    | transformingTo = transformingTo
                    , transformState = clamp 0 1 (transformDirection mech.transformState (dt / transformTime))
                }
            )
                |> Game.updateMech
                |> DeltaUnit unit.id

        moveTarget =
            if input.rally then
                DeltaPlayer unit.ownerId
                    (\g p ->
                        { p
                            | markerPosition = unit.position
                            , pathing = Pathfinding.makePaths g (vec2Tile unit.position)
                        }
                    )
            else
                DeltaNone

        updatePosition =
            case Unit.transformMode mech of
                ToMech ->
                    walk

                ToPlane ->
                    fly

        newPosition =
            updatePosition dx game unit |> Game.clampToGameSize game 1

        moveMech =
            DeltaUnit unit.id (\g u -> { u | position = newPosition })

        moveViewport =
            DeltaPlayer unit.ownerId (\g p -> { p | viewportPosition = newPosition })

        reload =
            if unit.timeToReload > 0 then
                DeltaUnit unit.id (\g u -> { u | timeToReload = max 0 (u.timeToReload - dt) })
            else
                DeltaNone

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
            View.Mech.leftGunOffset mech.transformState unit.fireAngle |> Vec2.add unit.position

        rightOrigin =
            View.Mech.rightGunOffset mech.transformState unit.fireAngle |> Vec2.add unit.position

        deltaFire origin =
            Game.deltaAddProjectile { ownerId = unit.ownerId, position = origin, angle = aimAngle }

        fire =
            if input.fire && unit.timeToReload == 0 then
                DeltaList
                    [ DeltaUnit unit.id (\g u -> { u | timeToReload = Unit.mechReloadTime mech })
                    , deltaFire leftOrigin
                    , View.Gfx.deltaAddProjectileCase leftOrigin (aimAngle - pi - pi / 12)
                    , deltaFire rightOrigin
                    , View.Gfx.deltaAddProjectileCase rightOrigin (aimAngle + pi / 12)
                    ]
            else
                DeltaNone
    in
    DeltaList
        [ moveTarget
        , moveViewport
        , moveMech
        , reload
        , aim
        , fire
        , transform
        , repairDelta dt game unit mech
        ]


repairDelta : Seconds -> Game -> Unit -> MechComponent -> Delta
repairDelta dt game unit mech =
    if unit.integrity >= 1 then
        DeltaNone
    else
        let
            canRepair base =
                case base.maybeOccupied of
                    Nothing ->
                        False

                    Just occupied ->
                        (occupied.isActive && occupied.playerId == unit.ownerId && occupied.buildCompletion > 0)
                            && (Vec2.distanceSquared base.position unit.position < 3 * 3)
        in
        case List.Extra.find canRepair (Dict.values game.baseById) of
            Nothing ->
                DeltaNone

            Just base ->
                DeltaList
                    [ Base.deltaRepairUnit dt base.id unit.id
                    , View.Gfx.deltaAddBeam base.position unit.position ColorPattern.neutral
                    ]


fly : Vec2 -> Game -> Unit -> Vec2
fly dp game unit =
    Vec2.add unit.position dp


walk : Vec2 -> Game -> Unit -> Vec2
walk dp game unit =
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
        idealPosition
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
        vec2 fX fY
