module Game exposing (..)

import AStar
import ColorPattern exposing (ColorPattern)
import Dict exposing (Dict)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Random
import Set exposing (Set)


-- TODO move these out of here or rename the module?


tileDistance : Tile2 -> Tile2 -> Float
tileDistance =
    -- Manhattan distance
    AStar.straightLineCost


vectorDistance : Vec2 -> Vec2 -> Float
vectorDistance v1 v2 =
    -- Manhattan distance
    let
        ( x1, y1 ) =
            Vec2.toTuple v1

        ( x2, y2 ) =
            Vec2.toTuple v2
    in
    abs (x1 - x2) + abs (y1 - y2)


clampToRadius : Float -> Vec2 -> Vec2
clampToRadius radius v =
    let
        ll =
            Vec2.lengthSquared v
    in
    if ll <= radius * radius then
        v
    else
        Vec2.scale (radius / sqrt ll) v


vec2Tile : Vec2 -> Tile2
vec2Tile v =
    let
        ( x, y ) =
            Vec2.toTuple v
    in
    ( floor x, floor y )


tile2Vec : Tile2 -> Vec2
tile2Vec ( x, y ) =
    vec2 (toFloat x) (toFloat y)



--


type alias Id =
    Int


type alias Tile2 =
    ( Int, Int )



-- Players


type alias Player =
    { id : Id
    , colorPattern : ColorPattern
    , position : Vec2
    , markerPosition : Vec2
    }


type alias PlayerInput =
    { move : Vec2
    , fire : Bool
    }


neutralPlayerInput : PlayerInput
neutralPlayerInput =
    { move = vec2 0 0
    , fire = False
    }



-- Units


type UnitOrder
    = UnitOrderStay
    | UnitOrderFollowMarker
    | UnitOrderMoveTo Vec2
    | UnitOrderEnterBase Id


type alias Unit =
    { id : Id
    , order : UnitOrder
    , ownerId : Id
    , position : Vec2
    }



-- Bases

maximumDistanceForUnitToEnterBase =
  2.1

baseMaxContainedUnits =
  4

type alias Base =
    { id : Id
    , containedUnits : Int
    , maybeOwnerId : Maybe Id
    , position : Tile2
    }



-- Game


type alias Game =
    { baseById : Dict Id Base
    , unitById : Dict Id Unit
    , playerById : Dict Id Player

    -- includes terrain and bases
    , staticObstacles : Set Tile2

    -- this is the union between static obstacles and unit positions
    , unpassableTiles : Set Tile2

    -- random
    , seed : Random.Seed
    , shuffledColorPatterns : List ColorPattern
    }



-- Deltas


type Delta
    = MoveUnit Id Vec2
    | UnitEntersBase Id Id
    | MovePlayer Id Vec2
    | RepositionMarker Id Vec2
