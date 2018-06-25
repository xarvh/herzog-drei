module ProjectileThink exposing (..)

import Dict exposing (Dict)
import Game exposing (..)
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Unit
import UnitCollision
import View.Gfx
import View.Mech
import View.Sub


maxRange =
    Unit.mechShootRange


maxRangeSquared =
    maxRange * maxRange


speed =
    30.0


think : Seconds -> Game -> Projectile -> Delta
think dt game projectile =
    let
        oldPosition =
            projectile.position

        newPosition =
            Game.angleToVector projectile.angle
                |> Vec2.scale (speed * dt)
                |> Vec2.add oldPosition
    in
    if Vec2.distanceSquared projectile.spawnPosition newPosition > maxRangeSquared then
        Game.deltaRemoveProjectile projectile.id
    else
        case UnitCollision.closestEnemyToVectorOrigin oldPosition newPosition projectile.maybeTeamId game of
            Just unit ->
                deltaList
                    [ Game.deltaRemoveProjectile projectile.id
                    , View.Gfx.deltaAddExplosion (Vec2.add newPosition oldPosition |> Vec2.scale 0.5) 0.2
                    , deltaUnit unit.id (Unit.takeDamage projectile.damage)
                    ]

            Nothing ->
                deltaProjectile projectile.id (\g p -> { p | position = newPosition })
