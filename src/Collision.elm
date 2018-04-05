module Collision
    exposing
        ( Polygon
        , collisionPolygonVsPolygon
        )

{-| Convex polygon collision detection

Based on the fantastic explanation by Nilson Souto: <https://www.toptal.com/game/video-game-physics-part-ii-collision-detection-for-solid-objects>

-}

import Array
import Math.Vector2 as Vec2 exposing (Vec2, vec2)


type alias Polygon =
    List Vec2


type alias Segment =
    ( Vec2, Vec2 )


anySegment : (Segment -> Bool) -> Polygon -> Bool
anySegment f poly =
    let
        polyAsArray =
            Array.fromList poly

        length =
            Array.length polyAsArray

        getVertex index =
            case Array.get (index % length) polyAsArray of
                Just vertex ->
                    vertex

                Nothing ->
                    vec2 0 0

        segments =
            List.indexedMap (\index v -> ( getVertex index, getVertex (index + 1) )) poly
    in
    List.any f segments


rightHandNormal : Vec2 -> Vec2
rightHandNormal v =
    let
        ( x, y ) =
            Vec2.toTuple v
    in
    vec2 -y x


normalIsSeparatingAxis : Polygon -> Segment -> Bool
normalIsSeparatingAxis q ( pointA, pointB ) =
    let
        normal =
            Vec2.sub pointB pointA |> rightHandNormal

        isRightSide polygonVertex =
            Vec2.dot normal (Vec2.sub polygonVertex pointA) > 0
    in
    List.all isRightSide q


halfCollision : Polygon -> Polygon -> Bool
halfCollision p q =
    -- Try polygon p's normals as separating axies.
    -- If any of them does separe the polys, then the two polys are NOT intersecting
    not <| anySegment (normalIsSeparatingAxis q) p


collisionPolygonVsPolygon : Polygon -> Polygon -> Bool
collisionPolygonVsPolygon p q =
    halfCollision p q && halfCollision q p
