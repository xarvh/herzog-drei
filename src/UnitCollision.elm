module UnitCollision exposing (..)

import Collision
import Dict exposing (Dict)
import Game exposing (..)
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import View.Mech
import View.Sub


unitSize : Float
unitSize =
    0.5


unitToPolygon : Unit -> Collision.Polygon
unitToPolygon unit =
    case unit.component of
        UnitSub _ ->
            View.Sub.collider unit.moveAngle unit.position

        UnitMech mech ->
            View.Mech.collider mech.transformState unit.fireAngle unit.position


vector : Vec2 -> Vec2 -> Unit -> Bool
vector a b unit =
    let
        -- get an easy-to-compute circle centered in A that contains B
        d =
            Vec2.toRecord <| Vec2.sub a b

        radius =
            max (abs d.x) (abs d.y)

        minimumCollisionDistance =
            radius + unitSize
    in
    if Vec2.distanceSquared a unit.position > minimumCollisionDistance * minimumCollisionDistance then
        False
    else
        Collision.collisionPolygonVsPolygon [ a, b ] (unitToPolygon unit)


closestToVectorOrigin : Vec2 -> Vec2 -> (Unit -> Bool) -> Game -> Maybe Unit
closestToVectorOrigin origin destination filter game =
    let
        checkUnit : Id -> Unit -> List Unit -> List Unit
        checkUnit id unit list =
            if filter unit && vector origin destination unit then
                unit :: list
            else
                list
    in
    game.unitById
        |> Dict.foldl checkUnit []
        |> List.Extra.minimumBy (\u -> Vec2.distanceSquared origin u.position)


closestEnemyToVectorOrigin : Vec2 -> Vec2 -> Maybe TeamId -> Game -> Maybe Unit
closestEnemyToVectorOrigin origin destination maybeTeamId game =
    closestToVectorOrigin origin destination (\u -> u.maybeTeamId /= maybeTeamId) game
