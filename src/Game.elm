module Game exposing (..)

import AStar
import ColorPattern exposing (ColorPattern)
import Dict exposing (Dict)
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
            , markerPosition = position
            , colorPattern = colorPattern
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


type alias Projectile =
    { id : Id
    , ownerId : Id
    , position : Vec2
    , angle : Angle
    }


addProjectile : Projectile -> Game -> Game
addProjectile projectile game =
    let
        id =
            game.lastId + 1

        projectileById =
            Dict.insert id { projectile | id = id } game.projectileById
    in
    { game | projectileById = projectileById, lastId = id }


deltaAddProjectile : Projectile -> Delta
deltaAddProjectile p =
    addProjectile p |> DeltaGame


removeProjectile : Id -> Game -> Game
removeProjectile id game =
    { game | projectileById = Dict.remove id game.projectileById }


deltaRemoveProjectile : Id -> Delta
deltaRemoveProjectile id =
    removeProjectile id |> DeltaGame



-- Units


type UnitOrder
    = UnitOrderStay
    | UnitOrderFollowMarker
    | UnitOrderMoveTo Vec2
    | UnitOrderEnterBase Id


type UnitMode
    = UnitModeFree
    | UnitModeBase Id


type alias UnitTypeMechRecord =
    { transformState : Float
    , transformingTo : TransformMode
    }


type alias UnitTypeSubRecord =
    { mode : UnitMode
    , maybeTargetId : Maybe Id
    , order : UnitOrder
    }


type
    UnitType
    --TODO Record -> Component
    = UnitTypeMech UnitTypeMechRecord
    | UnitTypeSub UnitTypeSubRecord


type alias Unit =
    { id : Id
    , hp : Int
    , ownerId : Id
    , position : Vec2
    , timeToReload : Seconds

    --TODO: rename to 'extra'?
    , type_ : UnitType

    --
    , fireAngle : Float
    , lookAngle : Float
    , moveAngle : Float
    }


addUnit : Id -> Bool -> Vec2 -> Game -> ( Game, Unit )
addUnit ownerId isMech position game =
    let
        id =
            game.lastId + 1

        faceCenterOfMap =
            Vec2.negate position |> vecToAngle

        unit =
            { id = id
            , ownerId = ownerId
            , position = position
            , hp =
                if isMech then
                    40
                else
                    10
            , timeToReload = 0

            --
            , lookAngle = faceCenterOfMap
            , fireAngle = faceCenterOfMap
            , moveAngle = faceCenterOfMap

            --
            , type_ =
                if isMech then
                    UnitTypeMech
                        { transformState = 0
                        , transformingTo = ToMech
                        }
                else
                    UnitTypeSub
                        { order = UnitOrderFollowMarker
                        , mode = UnitModeFree
                        , maybeTargetId = Nothing
                        }
            }

        unitById =
            Dict.insert id unit game.unitById
    in
    ( { game | lastId = id, unitById = unitById }, unit )


removeUnit : Id -> Game -> Game
removeUnit id game =
    { game | unitById = Dict.remove id game.unitById }


updateUnitSubRecord : (UnitTypeSubRecord -> UnitTypeSubRecord) -> Game -> Unit -> Unit
updateUnitSubRecord updateSubRecord game unit =
    case unit.type_ of
        UnitTypeSub subRecord ->
            { unit | type_ = UnitTypeSub (updateSubRecord subRecord) }

        _ ->
            unit


updateUnitMechRecord : (UnitTypeMechRecord -> UnitTypeMechRecord) -> Game -> Unit -> Unit
updateUnitMechRecord updateMechRecord game unit =
    case unit.type_ of
        UnitTypeMech mechRecord ->
            { unit | type_ = UnitTypeMech (updateMechRecord mechRecord) }

        _ ->
            unit



-- Bases


type alias Base =
    { id : Id
    , isActive : Bool
    , containedUnits : Int
    , maybeOwnerId : Maybe Id
    , position : Tile2
    }


addBase : Tile2 -> Game -> ( Game, Base )
addBase position game =
    let
        id =
            game.lastId + 1

        base =
            { id = id
            , isActive = False
            , containedUnits = 0
            , maybeOwnerId = Nothing
            , position = position
            }

        baseById =
            Dict.insert id base game.baseById

        staticObstacles =
            Set.union (tiles base |> Set.fromList) game.staticObstacles
    in
    ( { game | lastId = id, staticObstacles = staticObstacles, baseById = baseById }, base )


tiles : Base -> List Tile2
tiles base =
    let
        ( x, y ) =
            base.position
    in
    [ ( x + 0, y - 1 )
    , ( x - 1, y - 1 )
    , ( x - 1, y + 0 )
    , ( x + 0, y + 0 )
    ]



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
    , playerById = Dict.empty
    , projectileById = Dict.empty
    , unitById = Dict.empty
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
