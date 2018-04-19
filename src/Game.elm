module Game exposing (..)

import AStar
import ColorPattern exposing (ColorPattern)
import Dict exposing (Dict)
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Random
import Random.List
import Set exposing (Set)
import Svg exposing (Svg)


-- Basic Types


type alias Seconds =
    Float


type alias Angle =
    Float


type alias Id =
    Int


type alias Tile2 =
    ( Int, Int )



-- Players


type TransformMode
    = ToMech
    | ToPlane


type alias Player =
    { id : Id
    , colorPattern : ColorPattern
    , markerPosition : Vec2
    , viewportPosition : Vec2
    }


addPlayer : Vec2 -> Game -> ( Game, Player )
addPlayer position game =
    let
        id =
            game.lastId + 1

        colorPatternCount colorPattern =
            game.playerById
                |> Dict.values
                |> List.filter (\player -> player.colorPattern == colorPattern)
                |> List.length

        colorPattern =
            game.shuffledColorPatterns
                |> List.sortBy colorPatternCount
                |> List.head
                |> Maybe.withDefault ColorPattern.neutral

        player =
            { id = id
            , colorPattern = colorPattern
            , markerPosition = position
            , viewportPosition = position
            }

        playerById =
            Dict.insert id player game.playerById
    in
    ( { game | playerById = playerById, lastId = id }, player )


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



-- Projectiles


type alias ProjectileSeed =
    { ownerId : Id
    , position : Vec2
    , angle : Angle
    }


type alias Projectile =
    { id : Id
    , ownerId : Id
    , position : Vec2
    , spawnPosition : Vec2
    , angle : Angle
    }


addProjectile : ProjectileSeed -> Game -> Game
addProjectile { ownerId, position, angle } game =
    let
        projectile =
            { id = game.lastId + 1
            , ownerId = ownerId
            , position = position
            , spawnPosition = position
            , angle = angle
            }

        projectileById =
            Dict.insert projectile.id projectile game.projectileById
    in
    { game | projectileById = projectileById, lastId = projectile.id }


deltaAddProjectile : ProjectileSeed -> Delta
deltaAddProjectile p =
    addProjectile p |> DeltaGame


removeProjectile : Id -> Game -> Game
removeProjectile id game =
    { game | projectileById = Dict.remove id game.projectileById }


deltaRemoveProjectile : Id -> Delta
deltaRemoveProjectile id =
    removeProjectile id |> DeltaGame



-- Units


type UnitMode
    = UnitModeFree
    | UnitModeBase Id


type alias MechComponent =
    { transformState : Float
    , transformingTo : TransformMode
    }


type alias SubComponent =
    { mode : UnitMode
    , maybeTargetId : Maybe Id
    }


type UnitComponent
    = UnitMech MechComponent
    | UnitSub SubComponent


type alias Unit =
    { id : Id
    , component : UnitComponent
    , ownerId : Id
    , integrity : Float
    , position : Vec2
    , timeToReload : Seconds

    --
    , fireAngle : Float
    , lookAngle : Float
    , moveAngle : Float
    }


addUnit : UnitComponent -> Id -> Vec2 -> Game -> ( Game, Unit )
addUnit component ownerId position game =
    let
        id =
            game.lastId + 1

        faceCenterOfMap =
            Vec2.negate position |> vecToAngle

        unit =
            { id = id
            , ownerId = ownerId
            , position = position
            , integrity = 1
            , timeToReload = 0
            , component = component

            --
            , lookAngle = faceCenterOfMap
            , fireAngle = faceCenterOfMap
            , moveAngle = faceCenterOfMap
            }

        unitById =
            Dict.insert id unit game.unitById
    in
    ( { game | lastId = id, unitById = unitById }, unit )


addSub : Id -> Vec2 -> Game -> ( Game, Unit )
addSub =
    { mode = UnitModeFree
    , maybeTargetId = Nothing
    }
        |> UnitSub
        |> addUnit


addMech : Id -> Vec2 -> Game -> ( Game, Unit )
addMech =
    { transformState = 0
    , transformingTo = ToMech
    }
        |> UnitMech
        |> addUnit


removeUnit : Id -> Game -> Game
removeUnit id game =
    { game | unitById = Dict.remove id game.unitById }


updateSub : (SubComponent -> SubComponent) -> Game -> Unit -> Unit
updateSub update game unit =
    case unit.component of
        UnitSub subRecord ->
            { unit | component = UnitSub (update subRecord) }

        _ ->
            unit


updateMech : (MechComponent -> MechComponent) -> Game -> Unit -> Unit
updateMech update game unit =
    case unit.component of
        UnitMech mech ->
            { unit | component = UnitMech (update mech) }

        _ ->
            unit



-- Bases


type BaseType
    = BaseMain
    | BaseSmall


type alias Base =
    { id : Id
    , type_ : BaseType
    , isActive : Bool
    , containedUnits : Int
    -- neutral bases have their id set to -1. Using a maybe was more trouble than it was worth.
    , ownerId : Id
    , position : Tile2
    , buildCompletion : Float
    }


-- Gfx


type GfxRender
    = Beam Vec2 Vec2 ColorPattern
    | Explosion Vec2 Float
    | ProjectileCase Vec2 Angle


type alias Gfx =
    { age : Seconds
    , maxAge : Seconds
    , render : GfxRender
    }



-- Game


type alias Game =
    { baseById : Dict Id Base
    , playerById : Dict Id Player
    , projectileById : Dict Id Projectile
    , unitById : Dict Id Unit
    , lastId : Id
    , maybeWinnerId : Maybe Id

    --
    , cosmetics : List Gfx

    -- map size, in tiles
    , halfWidth : Int
    , halfHeight : Int

    -- walls are just tile blockers
    , wallTiles : Set Tile2

    -- includes walls and bases
    , staticObstacles : Set Tile2

    -- this is the union between static obstacles and unit positions
    , unpassableTiles : Set Tile2

    -- random
    , seed : Random.Seed
    , shuffledColorPatterns : List ColorPattern
    }


new : Random.Seed -> Game
new seed =
    { baseById = Dict.empty
    , playerById = Dict.empty
    , projectileById = Dict.empty
    , unitById = Dict.empty
    , lastId = 0
    , maybeWinnerId = Nothing

    --
    , cosmetics = []
    , halfWidth = 20
    , halfHeight = 10
    , wallTiles = Set.empty
    , staticObstacles = Set.empty
    , unpassableTiles = Set.empty

    --
    , seed = seed
    , shuffledColorPatterns = Random.step (Random.List.shuffle ColorPattern.patterns) seed |> Tuple.first
    }



-- Deltas


type Delta
    = DeltaList (List Delta)
    | DeltaGame (Game -> Game)
    | DeltaPlayer Id (Game -> Player -> Player)
    | DeltaUnit Id (Game -> Unit -> Unit)
    | DeltaBase Id (Game -> Base -> Base)
    | DeltaProjectile Id (Game -> Projectile -> Projectile)



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



-- Geometry helpers


centeredTileInterval : Int -> List Int
centeredTileInterval length =
    List.range (-length // 2) ((length - 1) // 2)


squareArea : Int -> Tile2 -> List Tile2
squareArea sideLength ( centerX, centerY ) =
    let
        range =
            centeredTileInterval sideLength
    in
    range
        |> List.map (\x -> range |> List.map (\y -> ( centerX + x, centerY + y )))
        |> List.concat


squarePerimeter : Int -> Tile2 -> List Tile2
squarePerimeter sideLength center =
    let
        outer =
            squareArea sideLength center |> Set.fromList

        inner =
            squareArea (sideLength - 1) center |> Set.fromList
    in
    Set.diff outer inner |> Set.toList


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


clampToGameSize : Game -> Float -> Vec2 -> Vec2
clampToGameSize game radius v =
    let
        ( x, y ) =
            Vec2.toTuple v

        hw =
            toFloat game.halfWidth - radius

        hh =
            toFloat game.halfHeight - radius
    in
    vec2 (clamp -hw hw x) (clamp -hh hh y)


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


angleToVector : Float -> Vec2
angleToVector angle =
    vec2
        (sin angle)
        (cos angle)


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
