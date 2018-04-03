module Game.Projectile exposing (..)

import Game exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)


update : Seconds -> Projectile -> Maybe Projectile
update dt projectile =
    let
        speed =
            30.0

        position =
            Game.angleToVector projectile.angle
                |> Vec2.scale (speed * dt)
                |> Vec2.add projectile.position

        ( x, y ) =
            Vec2.toTuple position
    in
    if abs x > 10 then
        Nothing
    else if abs y > 10 then
        Nothing
    else
        Just { projectile | position = position }
