module ProjectileThink exposing (..)

import Dict exposing (Dict)
import Game exposing (..)
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Stats
import Unit
import UnitCollision
import View.Gfx
import View.Mech
import View.Sub


idToClass : ProjectileClassId -> ProjectileClass
idToClass id =
    case id of
        PlaneBullet ->
            Stats.bullet

        BigSubBullet ->
            Stats.bullet

        HeliRocket ->
            Stats.rocket


think : Seconds -> Game -> Projectile -> Delta
think dt game projectile =
    let
        oldPosition =
            projectile.position

        class =
            idToClass projectile.classId

        newPosition =
            Game.angleToVector projectile.angle
                |> Vec2.scale (class.speed * dt)
                |> Vec2.add oldPosition
    in
    if Vec2.distanceSquared projectile.spawnPosition newPosition > class.range * class.range then
        Game.deltaRemoveProjectile projectile.id
    else
        case UnitCollision.closestEnemyToVectorOrigin oldPosition newPosition projectile.maybeTeamId game of
            Just unit ->
                deltaList
                    [ Game.deltaRemoveProjectile projectile.id

                    -- TODO: different classes have different explosions
                    , View.Gfx.deltaAddExplosion (Vec2.add newPosition oldPosition |> Vec2.scale 0.5) 0.2
                    , case class.effect of
                        ProjectileDamage damage ->
                            deltaUnit unit.id (Unit.takeDamage damage)

                        ProjectileSplashDamage { radius, damage } ->
                            -- TODO: splash!
                            deltaUnit unit.id (Unit.takeDamage damage)
                    ]

            Nothing ->
                deltaProjectile projectile.id (\g p -> { p | position = newPosition })
