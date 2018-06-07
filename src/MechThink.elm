module MechThink exposing (..)

import Base
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
    0.5


aimControlThreshold : Float
aimControlThreshold =
    0.1



--


mechThink : InputState -> Seconds -> Game -> Unit -> MechComponent -> Delta
mechThink input dt game unit mech =
    let
        speed =
            case Unit.transformMode mech of
                ToMech ->
                    5.0

                ToFlyer ->
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
                    ToFlyer ->
                        if mech.transformState == 1 then
                            ToMech
                        else
                            mech.transformingTo

                    ToMech ->
                        if mech.transformState == 0 then
                            ToFlyer
                        else
                            mech.transformingTo
            else
                mech.transformingTo

        transformDirection =
            case transformingTo of
                ToMech ->
                    (-)

                ToFlyer ->
                    (+)

        transform =
            (\mech ->
                { mech
                    | transformingTo = transformingTo
                    , transformState = clamp 0 1 (transformDirection mech.transformState (dt / transformTime))
                }
            )
                |> Game.updateMech
                |> deltaUnit unit.id

        rally =
            if input.rally then
                case game.phase of
                    PhaseSetup ->
                        (\mech ->
                            { mech
                                | class =
                                    case mech.class of
                                        Plane ->
                                            Heli

                                        Heli ->
                                            Plane
                            }
                        )
                            |> Game.updateMech
                            |> deltaUnit unit.id

                    PhasePlay ->
                        case unit.maybeTeamId of
                            Nothing ->
                                deltaNone

                            Just teamId ->
                                deltaTeam teamId
                                    (\g t ->
                                        if g.time - t.markerTime < 1 then
                                            t
                                        else
                                            { t
                                                | markerPosition = unit.position
                                                , markerTime = g.time
                                                , pathing = Pathfinding.makePaths g (vec2Tile unit.position)
                                            }
                                    )
            else
                deltaNone

        updatePosition =
            case Unit.transformMode mech of
                ToMech ->
                    walk

                ToFlyer ->
                    fly

        newPosition =
            updatePosition dx game unit |> Game.clampToGameSize game 1

        moveMech =
            deltaUnit unit.id (\g u -> { u | position = newPosition })

        reload =
            if unit.timeToReload > 0 then
                deltaUnit unit.id (\g u -> { u | timeToReload = max 0 (u.timeToReload - dt) })
            else
                deltaNone

        aimDirection =
            case input.aim of
                AimAbsolute direction ->
                    direction

                AimRelative mousePosition ->
                    Vec2.sub mousePosition unit.position

        aimAngle =
            if Vec2.length aimDirection > aimControlThreshold then
                vecToAngle aimDirection
            else if Vec2.length input.move > aimControlThreshold then
                vecToAngle input.move
            else
                -- Keep old value
                unit.fireAngle

        aimDelta =
            (\g u ->
                { u
                    | lookAngle = Game.turnTo (5 * pi * dt) aimAngle u.lookAngle
                    , fireAngle = Game.turnTo (2 * pi * dt) aimAngle u.fireAngle
                }
            )
                |> deltaUnit unit.id

        leftOrigin =
            View.Mech.leftGunOffset mech.transformState unit.fireAngle |> Vec2.add unit.position

        rightOrigin =
            View.Mech.rightGunOffset mech.transformState unit.fireAngle |> Vec2.add unit.position

        deltaFire origin =
            Game.deltaAddProjectile { maybeTeamId = unit.maybeTeamId, position = origin, angle = aimAngle }

        fire =
            if input.fire && unit.timeToReload == 0 then
                deltaList
                    [ deltaUnit unit.id (\g u -> { u | timeToReload = Unit.mechReloadTime mech })
                    , deltaFire leftOrigin
                    , View.Gfx.deltaAddProjectileCase leftOrigin (aimAngle - pi - pi / 12)
                    , deltaFire rightOrigin
                    , View.Gfx.deltaAddProjectileCase rightOrigin (aimAngle + pi / 12)
                    ]
            else
                deltaNone
    in
    deltaList
        [ rally
        , moveMech
        , reload
        , aimDelta
        , fire
        , transform
        , repairDelta dt game unit mech
        ]


repairDelta : Seconds -> Game -> Unit -> MechComponent -> Delta
repairDelta dt game unit mech =
    if unit.integrity >= 1 then
        deltaNone
    else
        let
            canRepair base =
                case base.maybeOccupied of
                    Nothing ->
                        False

                    Just occupied ->
                        (occupied.isActive && occupied.maybeTeamId == unit.maybeTeamId && occupied.subBuildCompletion > 0)
                            && (Vec2.distanceSquared base.position unit.position < 3 * 3)
        in
        case List.Extra.find canRepair (Dict.values game.baseById) of
            Nothing ->
                deltaNone

            Just base ->
                deltaList
                    [ Base.deltaRepairUnit dt base.id unit.id
                    , View.Gfx.deltaAddRepairBeam base.position unit.position
                    , View.Gfx.deltaAddRepairBubbles 4 dt unit.position
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
