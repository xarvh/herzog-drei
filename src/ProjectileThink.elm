module ProjectileThink exposing (..)

import Dict exposing (Dict)
import Game exposing (..)
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Projectile
import Stats
import Unit
import UnitCollision
import View.Gfx
import View.Mech
import View.Sub


think : Seconds -> Game -> Projectile -> Delta
think dt game projectile =
    case projectile.maybeTargetId of
        Just targetId ->
            thinkSeeker dt game targetId projectile

        Nothing ->
            thinkStraight dt game projectile


thinkSeeker : Seconds -> Game -> Id -> Projectile -> Delta
thinkSeeker dt game targetId projectile =
    let
        class =
            Projectile.idToClass projectile.classId

        newPosition =
            Vec2.scale (class.speed * dt) (angleToVector projectile.angle) |> Vec2.add projectile.position
    in
    -- TODO move to Stats
    if game.time - projectile.spawnTime > 5 then
        thinkExplode game class projectile newPosition
    else
        case Dict.get targetId game.unitById of
            Nothing ->
                thinkExplode game class projectile newPosition

            Just target ->
                if Vec2.distanceSquared target.position newPosition < 1 then
                    thinkExplode game class projectile newPosition
                else
                    let
                        targetAngle =
                            vecToAngle (Vec2.sub target.position projectile.position)

                        turnSpeed =
                            -- TODO move to Stats
                            0.1 * turns 1

                        maxTurn =
                            turnSpeed * dt

                        newAngle =
                            turnTo maxTurn targetAngle projectile.angle
                    in
                    deltaList
                        [ deltaProjectile projectile.id (\g p -> { p | position = newPosition, angle = newAngle })
                        , deltaTrail dt class 0 projectile
                        ]


thinkStraight : Seconds -> Game -> Projectile -> Delta
thinkStraight dt game projectile =
    let
        oldPosition =
            projectile.position

        class =
            Projectile.idToClass projectile.classId

        age =
            game.time - projectile.spawnTime

        traveledDistance =
            0.5 * class.acceleration * age * age + class.speed * age

        newPosition =
            angleToVector projectile.angle
                |> Vec2.scale (min traveledDistance class.range)
                |> Vec2.add projectile.spawnPosition

        thinkNoCollision _ =
            if traveledDistance > class.range then
                thinkExplode game class projectile newPosition
            else
                deltaList
                    [ deltaProjectile projectile.id (\g p -> { p | position = newPosition })
                    , deltaTrail dt class age projectile
                    ]
    in
    if class.travelsAlongZ then
        thinkNoCollision ()
    else
        case UnitCollision.closestEnemyToVectorOrigin oldPosition newPosition projectile.maybeTeamId game of
            Just unit ->
                deltaList
                    [ thinkExplode game class projectile (Vec2.add newPosition oldPosition |> Vec2.scale 0.5)
                    , case class.effect of
                        ProjectileDamage damage ->
                            deltaUnit unit.id (Unit.takeDamage damage)

                        ProjectileSplashDamage _ ->
                            deltaNone
                    ]

            Nothing ->
                thinkNoCollision ()


deltaTrail : Seconds -> ProjectileClass -> Seconds -> Projectile -> Delta
deltaTrail dt class age projectile =
    if not class.trail then
        deltaNone
    else
        let
            sizeMultiplier =
                if class.travelsAlongZ then
                    Projectile.perspective age
                else
                    1
        in
        View.Gfx.deltaAddTrail
            { position = projectile.position
            , angle = projectile.angle
            , stretch = sizeMultiplier * (class.speed + class.acceleration * age) * dt
            }


thinkExplode : Game -> ProjectileClass -> Projectile -> Vec2 -> Delta
thinkExplode game class projectile position =
    deltaList
        [ Projectile.deltaRemove projectile.id
        , deltaShake 0.3
        , case class.effect of
            ProjectileSplashDamage { radius, damage } ->
                deltaList
                    [ View.Gfx.deltaAddExplosion position radius
                    , Unit.splashDamage game projectile.maybeTeamId position damage radius
                    ]

            _ ->
                View.Gfx.deltaAddExplosion position 0.2
        ]
