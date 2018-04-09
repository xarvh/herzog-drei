module ProjectileThink exposing (..)

import Collision
import Dict exposing (Dict)
import Game exposing (..)
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import View.Gfx


unitSize =
    0.5


unitToPolygon : Unit -> Collision.Polygon
unitToPolygon unit =
    [ Vec2.add (vec2 0 unitSize) unit.position
    , Vec2.add (vec2 unitSize 0) unit.position
    , Vec2.add (vec2 0 -unitSize) unit.position
    , Vec2.add (vec2 -unitSize 0) unit.position
    ]


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
        speed =
            30.0

        oldPosition =
            projectile.position

        newPosition =
            Game.angleToVector projectile.angle
                |> Vec2.scale (speed * dt)
                |> Vec2.add oldPosition

        collidedUnits =
            game.unitById
                |> Dict.filter (\id unit -> unit.ownerId /= projectile.ownerId)
                |> Dict.filter (checkUnitCollision oldPosition newPosition)
                |> Dict.values
    in
    case List.Extra.minimumBy (\u -> Vec2.distanceSquared oldPosition u.position) collidedUnits of
        Just unit ->
            DeltaList
                [ Game.deltaRemoveProjectile projectile.id
                , View.Gfx.deltaAddExplosion (Vec2.add newPosition oldPosition |> Vec2.scale 0.5) 0.2
                , DeltaUnit unit.id (\g u -> { u | hp = u.hp - 1 })
                ]

        Nothing ->
            let
                ( x, y ) =
                    Vec2.toTuple newPosition
            in
            -- TODO use game.size or something
            if abs x > 10 || abs y > 10 then
                Game.deltaRemoveProjectile projectile.id
            else
                DeltaProjectile projectile.id (\g p -> { p | position = newPosition })
