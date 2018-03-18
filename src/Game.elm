module Game exposing (..)

import AStar
import ColorPattern exposing (ColorPattern)
import Dict exposing (Dict)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Random
import Random.List
import Set exposing (Set)


-- Geometry helpers


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


vecToAngle : Vec2 -> Float
vecToAngle v =
    let
        ( x, y ) =
            Vec2.toTuple v
    in
    atan2 -x y


radiantsToDegrees : Float -> Float
radiantsToDegrees r =
    r * (180 / pi)


normalizeAngle : Float -> Float
normalizeAngle a =
    if a < -pi then
        a + 2 * pi
    else if a > pi then
        a - 2 * pi
    else
        a


turnTo : Float -> Float -> Float -> Float
turnTo maxTurn targetAngle currentAngle =
    (targetAngle - currentAngle)
        |> normalizeAngle
        |> clamp -maxTurn maxTurn
        |> (+) currentAngle
        |> normalizeAngle



-- Other stuff


playerColorPattern : Game -> Id -> ColorPattern
playerColorPattern game playerId =
    case Dict.get playerId game.playerById of
        Nothing ->
            ColorPattern.neutral

        Just player ->
            player.colorPattern



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


type UnitStatus
    = UnitStatusFree
    | UnitStatusInBase Id


unitAttackRange : Float
unitAttackRange =
    4.0


type alias Unit =
    { id : Id
    , order : UnitOrder
    , ownerId : Id
    , position : Vec2
    , movementAngle : Float
    , targetingAngle : Float
    , maybeTargetId : Maybe Id
    , status : UnitStatus
    }



-- Bases


maximumDistanceForUnitToEnterBase : Float
maximumDistanceForUnitToEnterBase =
    2.1


baseColorPattern : Game -> Base -> ColorPattern
baseColorPattern game base =
    base.maybeOwnerId
        |> Maybe.map (playerColorPattern game)
        |> Maybe.withDefault ColorPattern.neutral


baseCorners : Base -> List Vec2
baseCorners base =
    let
        ( x, y ) =
            base.position
                |> tile2Vec
                |> Vec2.toTuple

        r =
            0.8
    in
    [ vec2 (x + r) (y + r)
    , vec2 (x - r) (y + r)
    , vec2 (x - r) (y - r)
    , vec2 (x + r) (y - r)
    ]


baseMaxContainedUnits : Int
baseMaxContainedUnits =
    -- A very convoluted way to write `4`
    Base 0 False 0 Nothing ( 0, 0 )
        |> baseCorners
        |> List.length


type alias Base =
    { id : Id
    , isActive : Bool
    , containedUnits : Int
    , maybeOwnerId : Maybe Id
    , position : Tile2
    }



-- Game


type alias Game =
    { baseById : Dict Id Base
    , unitById : Dict Id Unit
    , playerById : Dict Id Player
    , lastId : Id

    -- includes terrain and bases
    , staticObstacles : Set Tile2

    -- this is the union between static obstacles and unit positions
    , unpassableTiles : Set Tile2

    -- random
    , seed : Random.Seed
    , shuffledColorPatterns : List ColorPattern
    }


init : Random.Seed -> Game
init seed =
    { baseById = Dict.empty
    , unitById = Dict.empty
    , playerById = Dict.empty
    , lastId = 0

    --
    , staticObstacles = Set.empty
    , unpassableTiles = Set.empty

    --
    , seed = seed
    , shuffledColorPatterns = Random.step (Random.List.shuffle ColorPattern.patterns) seed |> Tuple.first
    }


addStaticObstacles : List Tile2 -> Game -> Game
addStaticObstacles tiles game =
    { game | staticObstacles = Set.union (Set.fromList tiles) game.staticObstacles }



-- Deltas


type
    Delta
    -- TODO rename to `UnitMoves`
    = MoveUnit Id Float Vec2
    | UnitEntersBase Id Id
      -- TODO rename to `PlayerMoves`
    | MovePlayer Id Vec2
    | RepositionMarker Id Vec2
