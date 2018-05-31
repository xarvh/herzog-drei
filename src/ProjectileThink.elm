module ProjectileThink exposing (..)

import Collision
import Dict exposing (Dict)
import Game exposing (..)
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Unit
import View.Gfx
import View.Mech
import View.Sub


unitSize =
    0.5


maxRange =
    Unit.mechShootRange


maxRangeSquared =
    maxRange * maxRange


speed =
    30.0


unitToPolygon : Unit -> Collision.Polygon
unitToPolygon unit =
    case unit.component of
        UnitSub _ ->
            View.Sub.collider unit.moveAngle unit.position

        UnitMech mech ->
            View.Mech.collider mech.transformState unit.fireAngle unit.position


checkUnitCollision : Vec2 -> Vec2 -> Id -> Unit -> Bool
checkUnitCollision a b unitId unit =
    let
        -- get an easy-to-compute circle centered in A that contains B
        ( dx, dy ) =
            Vec2.toTuple <| Vec2.sub a b

        radius =
            max (abs dx) (abs dy)

        minimumCollisionDistance =
            radius + unitSize
    in
    if Vec2.distanceSquared a unit.position > minimumCollisionDistance * minimumCollisionDistance then
        False
    else
        Collision.collisionPolygonVsPolygon [ a, b ] (unitToPolygon unit)


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
        let
            collidedUnits =
                game.unitById
                    |> Dict.filter (\id unit -> unit.maybeTeamId /= projectile.maybeTeamId)
                    |> Dict.filter (checkUnitCollision oldPosition newPosition)
                    |> Dict.values
        in
        case List.Extra.minimumBy (\u -> Vec2.distanceSquared oldPosition u.position) collidedUnits of
            Just unit ->
                deltaList
                    [ Game.deltaRemoveProjectile projectile.id
                    , View.Gfx.deltaAddExplosion (Vec2.add newPosition oldPosition |> Vec2.scale 0.5) 0.2
                    , deltaUnit unit.id (Unit.takeDamage Unit.mechShootDamage)
                    ]

            Nothing ->
                deltaProjectile projectile.id (\g p -> { p | position = newPosition })
