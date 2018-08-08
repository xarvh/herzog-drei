module MechThink exposing (..)

import Base
import Dict exposing (Dict)
import Game exposing (..)
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Mech
import Pathfinding
import Projectile
import Random
import Set exposing (Set)
import Stats
import Unit
import UnitCollision
import View.Gfx
import View.Mech


controlThreshold : Float
controlThreshold =
    0.1


nextClass : MechClass -> MechClass
nextClass class =
    case class of
        Plane ->
            Heli

        Heli ->
            Blimp

        Blimp ->
            Plane


mechCanMoveOrTransform : Game -> Unit -> MechComponent -> Bool
mechCanMoveOrTransform game unit mech =
    case ( mech.class, Mech.transformMode mech ) of
        ( Heli, ToMech ) ->
            case unit.maybeCharge of
                Just (Charging chargeStart) ->
                    False

                Just (Stretching stretchStart) ->
                    False

                _ ->
                    True

        _ ->
            True


mechSpeed : MechComponent -> Float
mechSpeed mech =
    case Mech.transformMode mech of
        ToMech ->
            case mech.class of
                Plane ->
                    5.0

                Heli ->
                    7.0

                Blimp ->
                    5.0

        ToFlyer ->
            case mech.class of
                Plane ->
                    18.0

                Heli ->
                    12.0

                Blimp ->
                    8.0


mechTransformTo : Bool -> MechComponent -> TransformMode
mechTransformTo hasFreeGround mech =
    case mech.transformingTo of
        ToFlyer ->
            if mech.transformState == 1 && hasFreeGround then
                ToMech
            else
                mech.transformingTo

        ToMech ->
            if mech.transformState == 0 then
                ToFlyer
            else
                mech.transformingTo


mechThink : ( InputState, InputState ) -> Seconds -> Game -> Unit -> MechComponent -> Delta
mechThink ( previousInput, currentInput ) dt game unit mech =
    let
        mode =
            Mech.transformMode mech

        canMoveOrTransform =
            mechCanMoveOrTransform game unit mech

        isAiming =
            Vec2.length aimDirection > controlThreshold

        isMoving =
            canMoveOrTransform && Vec2.length currentInput.move > controlThreshold

        newPosition =
            if not isMoving then
                unit.position
            else
                let
                    updatePosition =
                        case mode of
                            ToMech ->
                                walk

                            ToFlyer ->
                                fly

                    dx =
                        currentInput.move
                            |> clampToRadius 1
                            |> Vec2.scale (mechSpeed mech * dt)
                in
                updatePosition dx game unit |> Game.clampToGameSize game 1

        -- Transform
        hasFreeGround =
            Set.member (vec2Tile newPosition) game.staticObstacles |> not

        transformingTo =
            if not (currentInput.transform && canMoveOrTransform) then
                mech.transformingTo
            else
                mechTransformTo hasFreeGround mech

        transformDirection =
            case transformingTo of
                ToMech ->
                    (-)

                ToFlyer ->
                    (+)

        updateTransform m =
            { m
                | transformingTo = transformingTo
                , transformState = clamp 0 1 (transformDirection mech.transformState (dt / Stats.transformTime))
            }

        -- Aiming
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

        updateAim u =
            { u
                | lookAngle = Game.turnTo (5 * pi * dt) aimAngle u.lookAngle
                , fireAngle = Game.turnTo (2 * pi * dt) aimAngle u.fireAngle
            }

        -- Fire
        fire =
            if mech.class == Heli then
                heliFireDelta dt game unit mech currentInput.fire
            else if not currentInput.fire then
                deltaNone
            else if mech.class == Blimp && mode == ToFlyer then
                vampireDelta dt game unit mech newPosition
            else
                attackDelta game unit mech

        -- Passive
        deltaPassive =
            case mech.class of
                Plane ->
                    case mode of
                        ToFlyer ->
                            repairAllies dt game unit

                        ToMech ->
                            repairSelf dt unit

                Heli ->
                    deltaNone

                Blimp ->
                    deltaNone

        -- Rally
        rally =
            if currentInput.rally && not previousInput.rally then
                deltaRally game unit
            else
                deltaNone

        -- Unit
        update g u =
            { u | position = newPosition }
                |> updateAim
                |> updateMech updateTransform g
    in
    deltaList
        [ deltaUnit unit.id update
        , rally
        , fire
        , repairDelta dt game unit mech
        , deltaPassive
        ]


deltaRally : Game -> Unit -> Delta
deltaRally game unit =
    case game.mode of
        GameModeTeamSelection _ ->
            deltaUnit unit.id (\g u -> Game.updateMech (\m -> { m | class = nextClass m.class }) g { u | maybeCharge = Nothing })

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



{-
   ---


   toDoNow : { startTime : Seconds, totalDuration : Seconds, totalEvents : Int, currentTime : Seconds, elapsedSinceLastUpdate : Seconds } -> Int
   toDoNow { startTime, totalDuration, totalEvents, currentTime, elapsedSinceLastUpdate } =
       let
           alreadyDone =
               (currentTime - startTime) * toFloat totalEvents / totalDuration |> floor

           toBeDoneByNow =
               (currentTime - startTime + elapsedSinceLastUpdate) * toFloat totalEvents / totalDuration |> floor |> min totalEvents
       in
       toBeDoneByNow - alreadyDone
-}


heliFireDelta : Seconds -> Game -> Unit -> MechComponent -> Bool -> Delta
heliFireDelta dt game unit mech isFiring =
    let
        deltaCharge : Charge -> Delta
        deltaCharge charge =
            deltaUnit unit.id (\g u -> { u | maybeCharge = Just charge })

        deltaResetCharge : Delta
        deltaResetCharge =
            deltaUnit unit.id (\g u -> { u | maybeCharge = Nothing })
    in
    case unit.maybeCharge of
        Nothing ->
            if not isFiring then
                deltaNone
            else if Mech.transformMode mech == ToFlyer then
                attackDelta game unit mech
            else
                deltaList
                    [ deltaCharge (Charging game.time)
                    , attackDelta game unit mech
                    ]

        Just (Charging startTime) ->
            if not isFiring then
                deltaResetCharge
            else if game.time - startTime >= Stats.heli.chargeTime then
                deltaList
                    [ deltaCharge (Stretching game.time)
                    , fireUpwardSalvo game unit
                    ]
            else
                deltaNone

        Just (Stretching startTime) ->
            if isFiring && game.time - startTime < Stats.heli.maxStretchTime then
                deltaNone
            else
                deltaList
                    [ deltaCharge (Cooldown game.time)
                    , spawnDownwardSalvo game unit (game.time - startTime)
                    ]

        Just (Cooldown startTime) ->
            if game.time - startTime > Stats.heli.cooldown then
                deltaResetCharge
            else
                deltaNone


fireUpwardSalvo : Game -> Unit -> Delta
fireUpwardSalvo game unit =
    let
        intervalBetweenRockets =
            0.1

        indexToDelta index =
            deltaLater (intervalBetweenRockets * toFloat index) (spawnUpwardRocket game unit index)
    in
    List.range 0 (Stats.heli.salvoSize - 1)
        |> List.map indexToDelta
        |> deltaList


spawnUpwardRocket : Game -> Unit -> Int -> Delta
spawnUpwardRocket game unit salvoIndex =
    let
        ( da, dp ) =
            case modBy 3 salvoIndex of
                0 ->
                    ( -1, vec2 0 0 )

                1 ->
                    ( 0, vec2 0.1 0 )

                _ ->
                    ( 1, vec2 0.2 0 )
    in
    Projectile.deltaAdd
        { maybeTeamId = unit.maybeTeamId
        , position = Vec2.add dp unit.position
        , angle = degrees (da + 0.7 * toFloat salvoIndex)
        , classId = UpwardSalvo
        , maybeTargetId = Nothing
        }


spawnDownwardRocketLater : Unit -> Int -> Vec2 -> Delta
spawnDownwardRocketLater unit index destination =
    let
        delay =
            toFloat index * 0.06
    in
    deltaLater delay (spawnDownwardRocket { target = destination, maybeTeamId = unit.maybeTeamId })


spawnDownwardRocket : { target : Vec2, maybeTeamId : Maybe TeamId } -> Delta
spawnDownwardRocket { target, maybeTeamId } =
    let
        angle =
            degrees 160

        direction =
            angleToVector angle

        origin =
            Vec2.sub target (Vec2.scale Stats.downwardSalvo.range direction)
    in
    Projectile.deltaAdd
        { maybeTeamId = maybeTeamId
        , position = origin
        , angle = angle
        , classId = DownwardSalvo
        , maybeTargetId = Nothing
        }


spawnDownwardSalvo : Game -> Unit -> Seconds -> Delta
spawnDownwardSalvo game unit stretchTime =
    Mech.heliSalvoPositions stretchTime unit
        |> List.indexedMap (spawnDownwardRocketLater unit)
        |> deltaList


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
    Unit.filterAndMapAll game
        (\u -> u.maybeTeamId == unit.maybeTeamId && Vec2.distance u.position unit.position < Stats.plane.repairRange)
        (repairTargetDelta dt unit)
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
    if Mech.transformMode mech == ToMech then
        deltaNone
    else
        let
            deltas =
                Unit.filterAndMapAll game
                    (\u -> u.maybeTeamId /= unit.maybeTeamId && Vec2.distance u.position unit.position < Stats.blimp.vampireRange)
                    (vampireTargetDelta dt unit)
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
            Vec2.add start (vec2 0 Stats.blimp.vampireRange |> rotateVector angle)
    in
    View.Gfx.deltaAddVampireBeam start end



--


randomVampire : Seconds -> Unit -> Game -> Angle -> Game
randomVampire dt unit game angle =
    let
        start =
            unit.position

        end =
            Vec2.add start (vec2 0 Stats.blimp.vampireRange |> rotateVector angle)

        gfx =
            { duration = dt
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
    if game.time < unit.reloadEndTime then
        deltaNone
    else
        let
            leftOrigin =
                View.Mech.leftGunOffset mech.transformState unit.fireAngle |> Vec2.add unit.position

            rightOrigin =
                View.Mech.rightGunOffset mech.transformState unit.fireAngle |> Vec2.add unit.position

            deltaFire classId maybeTargetId origin =
                Projectile.deltaAdd
                    { maybeTeamId = unit.maybeTeamId
                    , position = origin
                    , angle = unit.fireAngle
                    , classId = classId
                    , maybeTargetId = maybeTargetId
                    }

            mode =
                Mech.transformMode mech
        in
        deltaList
            [ deltaUnit unit.id (\g u -> { u | reloadEndTime = game.time + Mech.reloadTime mech })
            , case mech.class of
                Blimp ->
                    deltaList
                        [ beamAttackDelta game unit mech leftOrigin
                        , beamAttackDelta game unit mech rightOrigin
                        ]

                Heli ->
                    case mode of
                        ToFlyer ->
                            deltaList
                                [ deltaFire HeliRocket Nothing leftOrigin
                                , deltaFire HeliRocket Nothing rightOrigin
                                ]

                        ToMech ->
                            let
                                maybeTargetId =
                                    game.unitById
                                        |> Dict.values
                                        |> List.filter (\t -> t.maybeTeamId /= unit.maybeTeamId && Unit.isMech t)
                                        |> List.map (\t -> ( t.id, missileTargetPriority unit t ))
                                        |> List.Extra.maximumBy Tuple.second
                                        |> Maybe.map Tuple.first
                            in
                            deltaList
                                [ deltaFire HeliMissile maybeTargetId leftOrigin
                                , deltaFire HeliMissile maybeTargetId rightOrigin
                                ]

                Plane ->
                    deltaList
                        [ deltaFire PlaneBullet Nothing leftOrigin
                        , View.Gfx.deltaAddProjectileCase leftOrigin (unit.fireAngle - pi - pi / 12)
                        , deltaFire PlaneBullet Nothing rightOrigin
                        , View.Gfx.deltaAddProjectileCase rightOrigin (unit.fireAngle + pi / 12)
                        , deltaShake 0.02
                        ]
            ]


missileTargetPriority : Unit -> Unit -> Float
missileTargetPriority shooter target =
    let
        dp =
            Vec2.sub shooter.position target.position

        deltaAngle =
            dp
                |> vecToAngle
                |> turnTo (2 * pi) shooter.fireAngle
                |> abs

        distance =
            Vec2.length dp
    in
    0 - distance - 10 * deltaAngle


beamAttackDelta : Game -> Unit -> MechComponent -> Vec2 -> Delta
beamAttackDelta game unit mech start =
    let
        alongBeamLength =
            vec2 0 1 |> rotateVector unit.fireAngle

        alongBeamWidth =
            rotateVector (pi / 2) alongBeamLength

        halfWidth =
            0.2

        lengthV =
            Vec2.scale Stats.blimp.beamRange alongBeamLength

        end =
            Vec2.add start lengthV

        a =
            Vec2.scale halfWidth alongBeamWidth |> Vec2.add start

        b =
            Vec2.scale -halfWidth alongBeamWidth |> Vec2.add start

        c =
            Vec2.add b lengthV

        d =
            Vec2.add a lengthV

        beamPolygon =
            [ a, b, c, d ]

        maybeTarget =
            UnitCollision.enemiesVsPolygon beamPolygon unit.maybeTeamId game
                |> List.Extra.minimumBy (\target -> Vec2.distanceSquared unit.position target.position)
    in
    case maybeTarget of
        Nothing ->
            View.Gfx.deltaAddBeam start end (teamColorPattern game unit.maybeTeamId)

        Just target ->
            let
                length =
                    Vec2.distance start target.position

                newEnd =
                    Vec2.add start (Vec2.scale length alongBeamLength)
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
