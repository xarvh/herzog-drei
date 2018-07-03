module UnitCollision exposing (..)

import Collision
import Dict exposing (Dict)
import Game exposing (..)
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Unit
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



-- unit vs polygon


enemiesVsPolygon : List Vec2 -> Maybe TeamId -> Game -> List Unit
enemiesVsPolygon polygon maybeTeamId game =
    Unit.filterAndMapAll game
        (\u -> u.maybeTeamId /= maybeTeamId && Collision.collisionPolygonVsPolygon polygon (unitToPolygon u))
        identity



-- Unit vs vector


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


closestEnemyToVectorOrigin : Vec2 -> Vec2 -> Maybe TeamId -> Game -> Maybe Unit
closestEnemyToVectorOrigin origin destination maybeTeamId game =
    Unit.filterAndMapAll game
        (\u -> u.maybeTeamId /= maybeTeamId && vector origin destination u)
        identity
        |> List.Extra.minimumBy (\u -> Vec2.distanceSquared origin u.position)
