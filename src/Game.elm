module Game exposing (..)

import AStar
import ColorPattern exposing (ColorPattern)
import Dict exposing (Dict)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Random
import Random.List
import Set exposing (Set)
import Svg exposing (Svg)
import View.Gfx exposing (Gfx)


-- Basic Types


type alias Seconds =
    Float


type alias Id =
    Int


type alias Tile2 =
    ( Int, Int )



-- Players


type TransformMode
    = Mech
    | Plane


type alias Player =
    { id : Id
    , colorPattern : ColorPattern
    , position : Vec2
    , markerPosition : Vec2
    , timeToReload : Seconds

    --
    , headAngle : Float
    , topAngle : Float
    , transformState : Float
    , transformingTo : TransformMode
    }


type alias PlayerInput =
    { aim : Vec2

    -- Mech attacks
    , fire : Bool

    -- Mech transforms or change base production
    , transform : Bool

    -- Change selected units
    -- Hold: select all units
    , switchUnit : Bool

    -- Rally selected units
    -- Hold: retreat
    , rally : Bool

    -- Mech moves
    , move : Vec2
    }


neutralPlayerInput : PlayerInput
neutralPlayerInput =
    { aim = vec2 0 1
    , fire = False
    , transform = False
    , switchUnit = False
    , rally = False
    , move = vec2 0 0
    }



-- Units


type UnitOrder
    = UnitOrderStay
    | UnitOrderFollowMarker
    | UnitOrderMoveTo Vec2
    | UnitOrderEnterBase Id


type UnitMode
    = UnitModeFree
    | UnitModeBase Id


type alias Unit =
    { id : Id
    , order : UnitOrder
    , ownerId : Id
    , mode : UnitMode

    --
    , position : Vec2
    , movementAngle : Float

    --
    , hp : Int
    , maybeTargetId : Maybe Id
    , timeToReload : Seconds
    , targetingAngle : Float
    }



-- Bases


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
    , playerById : Dict Id Player
    , unitById : Dict Id Unit
    , lastId : Id

    --
    , cosmetics : List Gfx

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
    , cosmetics = []
    , staticObstacles = Set.empty
    , unpassableTiles = Set.empty

    --
    , seed = seed
    , shuffledColorPatterns = Random.step (Random.List.shuffle ColorPattern.patterns) seed |> Tuple.first
    }



-- Deltas


type Delta
    = DeltaGame (Game -> Game)
    | DeltaPlayer Id (Game -> Player -> Player)
    | DeltaUnit Id (Game -> Unit -> Unit)
    | DeltaBase Id (Game -> Base -> Base)



-- Game manipulation helpers


updateBase : Base -> Game -> Game
updateBase base game =
    { game | baseById = Dict.insert base.id base game.baseById }


updatePlayer : Player -> Game -> Game
updatePlayer player game =
    { game | playerById = Dict.insert player.id player game.playerById }


updateUnit : Unit -> Game -> Game
updateUnit unit game =
    { game | unitById = Dict.insert unit.id unit game.unitById }


with : (Game -> Dict Id a) -> Game -> Id -> (a -> Game) -> Game
with getter game id fn =
    case Dict.get id (getter game) of
        Nothing ->
            game

        Just item ->
            fn item


withBase : Game -> Id -> (Base -> Game) -> Game
withBase =
    with .baseById


withPlayer : Game -> Id -> (Player -> Game) -> Game
withPlayer =
    with .playerById


withUnit : Game -> Id -> (Unit -> Game) -> Game
withUnit =
    with .unitById



-- Obstacles


addStaticObstacles : List Tile2 -> Game -> Game
addStaticObstacles tiles game =
    { game | staticObstacles = Set.union (Set.fromList tiles) game.staticObstacles }



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
    atan2 x y


normalizeAngle : Float -> Float
normalizeAngle angle =
    if angle < -pi then
        normalizeAngle (angle + 2 * pi)
    else if angle >= pi then
        normalizeAngle (angle - 2 * pi)
    else
        angle


turnTo : Float -> Float -> Float -> Float
turnTo maxTurn targetAngle currentAngle =
    (targetAngle - currentAngle)
        |> normalizeAngle
        |> clamp -maxTurn maxTurn
        |> (+) currentAngle
        |> normalizeAngle


rotateVector : Float -> Vec2 -> Vec2
rotateVector angle v =
    let
        ( x, y ) =
            Vec2.toTuple v

        sinA =
            sin -angle

        cosA =
            cos angle
    in
    vec2
        (x * cosA - y * sinA)
        (x * sinA + y * cosA)



-- Color Patterns


playerColorPattern : Game -> Id -> ColorPattern
playerColorPattern game playerId =
    case Dict.get playerId game.playerById of
        Nothing ->
            ColorPattern.neutral

        Just player ->
            player.colorPattern



-- Gfx helpers


cosmeticToDelta : Gfx -> Delta
cosmeticToDelta c =
    DeltaGame <| \game -> { game | cosmetics = c :: game.cosmetics }


deltaAddGfxBeam =
    View.Gfx.beam cosmeticToDelta


deltaAddGfxExplosion =
    View.Gfx.explosion cosmeticToDelta
