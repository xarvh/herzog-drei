module MechThink exposing (..)

import Base
import Dict exposing (Dict)
import Game exposing (..)
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Pathfinding
import Projectile
import Random
import Set exposing (Set)
import Stats
import Unit
import UnitCollision
import View.Gfx
import View.Mech


-- globals


transformTime : Float
transformTime =
    0.5


aimControlThreshold : Float
aimControlThreshold =
    0.1


vampireRange =
    3


repairRange =
    5



--


nextClass : MechClass -> MechClass
nextClass class =
    case class of
        Plane ->
            Heli

        Heli ->
            Blimp

        Blimp ->
            Plane


mechThink : ( InputState, InputState ) -> Seconds -> Game -> Unit -> MechComponent -> Delta
mechThink ( previousInput, currentInput ) dt game unit mech =
    let
        isAiming =
            Vec2.length aimDirection > aimControlThreshold

        isMoving =
            Vec2.length currentInput.move > aimControlThreshold

        speed =
            case Unit.transformMode mech of
                ToMech ->
                    5.0

                ToFlyer ->
                    case mech.class of
                        Plane ->
                            18.0

                        Heli ->
                            12.0

                        Blimp ->
                            8.0

        dx =
            currentInput.move
                |> clampToRadius 1
                |> Vec2.scale (speed * dt)

        rally =
            if currentInput.rally && not previousInput.rally then
                case game.mode of
                    GameModeTeamSelection _ ->
                        (\m -> { m | class = nextClass m.class })
                            |> Game.updateMech
                            |> deltaUnit unit.id

                    GameModeVersus ->
                        case unit.maybeTeamId of
                            Nothing ->
                                deltaNone

                            Just teamId ->
                                deltaTeam teamId
                                    (\g t ->
                                        if g.time - t.markerTime < 0.2 then
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

        hasFreeGround u =
            Set.member (vec2Tile newPosition) game.staticObstacles |> not

        transformingTo =
            if currentInput.transform then
                case mech.transformingTo of
                    ToFlyer ->
                        if mech.transformState == 1 && hasFreeGround unit then
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
            (\m ->
                { m
                    | transformingTo = transformingTo
                    , transformState = clamp 0 1 (transformDirection mech.transformState (dt / transformTime))
                }
            )
                |> Game.updateMech
                |> deltaUnit unit.id

        aimDirection =
            case currentInput.aim of
                AimAbsolute direction ->
                    direction

                AimRelative mousePosition ->
                    Vec2.sub mousePosition unit.position

        aimAngle =
            if isAiming then
                vecToAngle aimDirection
            else if isMoving then
                vecToAngle currentInput.move
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

        fire =
            if mech.class == Blimp && Unit.transformMode mech == ToFlyer then
                if currentInput.fire then
                    vampireDelta dt game unit mech newPosition
                else
                    deltaNone
            else if currentInput.fire && game.time >= unit.reloadEndTime then
                deltaList
                    [ deltaUnit unit.id (\g u -> { u | reloadEndTime = game.time + Unit.mechReloadTime mech })
                    , attackDelta game unit mech
                    ]
            else
                deltaNone
    in
    deltaList
        [ rally
        , moveMech
        , aimDelta
        , fire
        , transform
        , repairDelta dt game unit mech
        , case mech.class of
            Plane ->
                case Unit.transformMode mech of
                    ToFlyer ->
                        repairAllies dt game unit

                    ToMech ->
                        repairSelf dt unit

            Heli ->
                deltaNone

            Blimp ->
                deltaNone
        ]


repairSelf : Seconds -> Unit -> Delta
repairSelf dt unit =
    if unit.integrity >= 1 then
        deltaNone
    else
        let
            repairRate =
                0.05

            repair =
                dt * repairRate
        in
        deltaList
            [ deltaUnit unit.id (\g u -> { u | integrity = u.integrity + repair |> min 1 })
            , View.Gfx.deltaAddRepairBubbles 1 dt unit.position
            ]


repairAllies : Seconds -> Game -> Unit -> Delta
repairAllies dt game unit =
    game.unitById
        |> Dict.values
        |> List.filter (\u -> u.maybeTeamId == unit.maybeTeamId && Vec2.distance u.position unit.position < repairRange)
        |> List.map (repairTargetDelta dt unit)
        |> deltaList


repairTargetDelta : Seconds -> Unit -> Unit -> Delta
repairTargetDelta dt healer target =
    if healer == target || target.integrity >= 1 then
        deltaNone
    else
        let
            repairRate =
                0.4

            repair =
                dt * repairRate
        in
        deltaList
            [ deltaUnit target.id (\g u -> { u | integrity = u.integrity + repair |> min 1 })
            , View.Gfx.deltaAddRepairBubbles 0.1 dt target.position
            , View.Gfx.deltaAddRepairBeam healer.position target.position
            ]


vampireDelta : Seconds -> Game -> Unit -> MechComponent -> Vec2 -> Delta
vampireDelta dt game unit mech newPosition =
    if Unit.transformMode mech == ToMech then
        deltaNone
    else
        let
            deltas =
                game.unitById
                    |> Dict.values
                    |> List.filter (\u -> u.maybeTeamId /= unit.maybeTeamId && Vec2.distance u.position unit.position < vampireRange)
                    |> List.map (vampireTargetDelta dt unit)
        in
        if deltas /= [] then
            deltaList deltas
        else
            emptyVampire dt unit newPosition game


emptyVampire : Seconds -> Unit -> Vec2 -> Game -> Delta
emptyVampire dt unit newPosition game =
    let
        angle =
            normalizeAngle (game.time + toFloat unit.id)

        start =
            newPosition

        end =
            Vec2.add start (vec2 0 vampireRange |> rotateVector angle)
    in
    View.Gfx.deltaAddVampireBeam start end


{-| TODO move to game.elm?
angleGenerator : Random.Generator Angle
angleGenerator =
Random.float -pi pi

updateRandom : Random.Generator a -> (Game -> a -> Game) -> Game -> Game
updateRandom generator update game =
let
( value, seed ) =
Random.step generator game.seed
in
update { game | seed = seed } value

deltaRandom : Random.Generator a -> (Game -> a -> Game) -> Delta
deltaRandom generator update =
deltaGame (updateRandom generator update)

-}



--


randomVampire : Seconds -> Unit -> Game -> Angle -> Game
randomVampire dt unit game angle =
    let
        start =
            unit.position

        end =
            Vec2.add start (vec2 0 vampireRange |> rotateVector angle)

        gfx =
            { age = 0
            , maxAge = dt
            , render = GfxFractalBeam start end View.Gfx.vampireRed
            }
    in
    View.Gfx.addGfx gfx game


vampireTargetDelta : Seconds -> Unit -> Unit -> Delta
vampireTargetDelta dt attacker target =
    let
        damageRate =
            case target.component of
                UnitMech _ ->
                    40

                UnitSub sub ->
                    14

        healRatio =
            0.005

        damage =
            dt * damageRate

        repair =
            damage * healRatio
    in
    deltaList
        [ deltaUnit attacker.id (\g u -> { u | integrity = u.integrity + repair |> min 1 })
        , deltaUnit target.id (Unit.takePiercingDamage damage)
        , View.Gfx.deltaAddRepairBubbles 1.0 dt attacker.position
        , View.Gfx.deltaAddVampireBeam attacker.position target.position
        ]


attackDelta : Game -> Unit -> MechComponent -> Delta
attackDelta game unit mech =
    let
        leftOrigin =
            View.Mech.leftGunOffset mech.transformState unit.fireAngle |> Vec2.add unit.position

        rightOrigin =
            View.Mech.rightGunOffset mech.transformState unit.fireAngle |> Vec2.add unit.position

        deltaFire classId origin =
            Projectile.deltaAdd
                { maybeTeamId = unit.maybeTeamId
                , position = origin
                , angle = unit.fireAngle
                , classId = classId
                }
    in
    case mech.class of
        Blimp ->
            deltaList
                [ beamAttackDelta game unit mech leftOrigin
                , beamAttackDelta game unit mech rightOrigin
                ]

        Heli ->
            deltaList
                [ deltaFire HeliRocket leftOrigin
                , deltaFire HeliRocket rightOrigin
                ]

        Plane ->
            deltaList
                [ deltaFire PlaneBullet leftOrigin
                , View.Gfx.deltaAddProjectileCase leftOrigin (unit.fireAngle - pi - pi / 12)
                , deltaFire PlaneBullet rightOrigin
                , View.Gfx.deltaAddProjectileCase rightOrigin (unit.fireAngle + pi / 12)
                ]


beamAttackDelta : Game -> Unit -> MechComponent -> Vec2 -> Delta
beamAttackDelta game unit mech start =
    let
        direction =
            vec2 0 1 |> rotateVector unit.fireAngle

        end =
            Vec2.add start (Vec2.scale Stats.blimp.beamRange direction)
    in
    case UnitCollision.closestEnemyToVectorOrigin start end unit.maybeTeamId game of
        Nothing ->
            View.Gfx.deltaAddBeam start end (teamColorPattern game unit.maybeTeamId)

        Just target ->
            let
                length =
                    Vec2.distance start target.position

                newEnd =
                    Vec2.add start (Vec2.scale length direction)
            in
            deltaList
                [ View.Gfx.deltaAddBeam start newEnd (teamColorPattern game unit.maybeTeamId)
                , deltaUnit target.id (Unit.takeDamage Stats.blimp.beamDamage)
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

            i =
                Vec2.toRecord idealPosition

            fX =
                clamp minX maxX i.x

            fY =
                clamp minY maxY i.y
        in
        vec2 fX fY
