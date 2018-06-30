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
                50
            else
                0

        traveledDistance =
            0.5 * a * age * age + class.speed * age

        newPosition =
            angleToVector projectile.angle
                |> Vec2.scale (min traveledDistance class.range)
                |> Vec2.add projectile.spawnPosition
    in
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
            if traveledDistance > class.range then
                thinkExplode game class projectile newPosition
            else
                deltaList
                    [ deltaProjectile projectile.id (\g p -> { p | position = newPosition })
                    , if class.trail then
                        View.Gfx.deltaAddTrail
                            { position = oldPosition
                            , angle = projectile.angle
                            , stretch = (class.speed + a * age) * dt
                            }
                      else
                        deltaNone
                    ]


thinkExplode : Game -> ProjectileClass -> Projectile -> Vec2 -> Delta
thinkExplode game class projectile position =
    -- TODO: different classes have different explosions
    deltaList
        [ Projectile.deltaRemove projectile.id
        , View.Gfx.deltaAddExplosion position 0.2
        ]
