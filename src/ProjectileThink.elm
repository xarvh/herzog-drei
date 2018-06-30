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
    let
        oldPosition =
            projectile.position

        class =
            Projectile.idToClass projectile.classId

        age =
            game.time - projectile.spawnTime

        a =
            if class.accelerates then
                30
            else
                0

        traveledDistance =
            0.5 * a * age * age + class.speed * age

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
                    , if class.trail then
                        let
                            sizeMultiplier =
                                if class.travelsAlongZ then
                                    Projectile.perspective age
                                else
                                    1
                        in
                        View.Gfx.deltaAddTrail
                            { position = oldPosition
                            , angle = projectile.angle
                            , stretch = sizeMultiplier * (class.speed + a * age) * dt
                            }
                      else
                        deltaNone
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


thinkExplode : Game -> ProjectileClass -> Projectile -> Vec2 -> Delta
thinkExplode game class projectile position =
    deltaList
        [ Projectile.deltaRemove projectile.id
        , case class.effect of
            ProjectileSplashDamage { radius, damage } ->
                deltaList
                    [ View.Gfx.deltaAddExplosion position radius
                    , Unit.splashDamage game projectile.maybeTeamId position damage radius
                    ]

            _ ->
                View.Gfx.deltaAddExplosion position 0.2
        ]
