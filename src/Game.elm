module Game exposing (..)

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



-- Team


type alias Team =
    { id : Id
    , colorPattern : ColorPattern
    , markerPosition : Vec2
    , markerTime : Seconds
    , pathing : Dict Tile2 Float
    }


addTeam : Game -> ( Game, Team )
addTeam game =
    let
        id =
            game.lastId + 1

        colorPatternCount colorPattern =
            game.teamById
                |> Dict.values
                |> List.filter (\team -> team.colorPattern == colorPattern)
                |> List.length

        colorPattern =
            game.shuffledColorPatterns
                |> List.sortBy colorPatternCount
                |> List.head
                |> Maybe.withDefault ColorPattern.neutral

        team =
            { id = id
            , colorPattern = colorPattern
            , markerPosition = vec2 0 0
            , markerTime = 0
            , pathing = Dict.empty
            }

        teamById =
            Dict.insert id team game.teamById
    in
    ( { game | teamById = teamById, lastId = id }, team )



-- Players


type alias Player =
    { teamId : Id
    , inputSourceKey : String
    , viewportPosition : Vec2
    }


type Aim
    = AimRelative Vec2
    | AimAbsolute Vec2


type alias PlayerInput =
    { aim : Aim

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
    { aim = AimAbsolute (vec2 0 0)
    , fire = False
    , transform = False
    , switchUnit = False
    , rally = False
    , move = vec2 0 0
    }



-- Projectiles


type alias ProjectileSeed =
    { teamId : Id
    , position : Vec2
    , angle : Angle
    }


type alias Projectile =
    { id : Id
    , teamId : Id
    , position : Vec2
    , spawnPosition : Vec2
    , angle : Angle
    }


addProjectile : ProjectileSeed -> Game -> Game
addProjectile { teamId, position, angle } game =
    let
        projectile =
            { id = game.lastId + 1
            , teamId = teamId
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
    addProjectile p |> deltaGame


removeProjectile : Id -> Game -> Game
removeProjectile id game =
    { game | projectileById = Dict.remove id game.projectileById }


deltaRemoveProjectile : Id -> Delta
deltaRemoveProjectile id =
    removeProjectile id |> deltaGame



-- Units


type UnitMode
    = UnitModeFree
    | UnitModeBase Id


type TransformMode
    = ToMech
    | ToPlane


type alias MechComponent =
    { transformState : Float
    , transformingTo : TransformMode
    , playerKey : String
    }


type alias SubComponent =
    { mode : UnitMode
    , targetId : Id
    }


type UnitComponent
    = UnitMech MechComponent
    | UnitSub SubComponent


type alias Unit =
    { id : Id
    , component : UnitComponent
    , teamId : Id
    , integrity : Float
    , position : Vec2
    , timeToReload : Seconds

    --
    , fireAngle : Float
    , lookAngle : Float
    , moveAngle : Float

    --
    , isLeavingBase : Bool
    }


addUnit : UnitComponent -> Id -> Vec2 -> Game -> ( Game, Unit )
addUnit component teamId position game =
    let
        id =
            game.lastId + 1

        ( x, y ) =
            Vec2.toTuple position

        -- When a newly constructed unit leaves the base, it will face the
        -- orhtogonal direction closest to the center.
        startAngle =
            case ( y > x, y > -x ) of
                ( True, True ) ->
                    -- base is above map center, unit exits down
                    pi

                ( False, True ) ->
                    -- base is right of map center, unit exits left
                    -pi / 2

                ( False, False ) ->
                    -- base is below map center, unit exits up
                    0

                ( True, False ) ->
                    -- base left of map center, unit exits right
                    pi / 2

        faceCenterOfMap =
            Vec2.negate position |> vecToAngle

        unit =
            { id = id
            , teamId = teamId
            , position = position
            , integrity = 1
            , timeToReload = 0
            , component = component

            --
            , lookAngle = startAngle
            , fireAngle = startAngle
            , moveAngle = startAngle

            --
            , isLeavingBase = True
            }

        unitById =
            Dict.insert id unit game.unitById
    in
    ( { game | lastId = id, unitById = unitById }, unit )


addSub : Id -> Vec2 -> Game -> ( Game, Unit )
addSub =
    { mode = UnitModeFree
    , targetId = -1
    }
        |> UnitSub
        |> addUnit


addMech : String -> Id -> Vec2 -> Game -> ( Game, Unit )
addMech playerKey =
    { transformState = 1
    , transformingTo = ToPlane
    , playerKey = playerKey
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


type alias BaseOccupied =
    { teamId : Id
    , unitIds : Set Id
    , isActive : Bool
    , subBuildCompletion : Float
    , mechBuildCompletions : List ( String, Float )
    }


type alias Base =
    { id : Id
    , type_ : BaseType
    , maybeOccupied : Maybe BaseOccupied
    , tile : Tile2
    , position : Vec2
    }



-- Gfx


type GfxRender
    = GfxBeam Vec2 Vec2 ColorPattern
    | GfxExplosion Vec2 Float
    | GfxProjectileCase Vec2 Angle
    | GfxRepairBeam Vec2 Vec2


type alias Gfx =
    { age : Seconds
    , maxAge : Seconds
    , render : GfxRender
    }



-- Game


type GamePhase
    = PhaseSetup
    | PhaseTransition
    | PhasePlay


type alias GameSize =
    { halfWidth : Int
    , halfHeight : Int
    }


type alias Game =
    { phase : GamePhase
    , maybeWinnerId : Maybe Id
    , time : Seconds

    -- entities
    , baseById : Dict Id Base
    , teamById : Dict Id Team
    , playerByKey : Dict String Player
    , projectileById : Dict Id Projectile
    , unitById : Dict Id Unit
    , lastId : Id

    --
    , cosmetics : List Gfx

    -- map size, in tiles
    , halfWidth : Int
    , halfHeight : Int

    -- walls are just tile blockers
    , wallTiles : Set Tile2

    -- includes walls and bases
    , staticObstacles : Set Tile2

    -- land units
    , dynamicObstacles : Set Tile2

    -- random
    , seed : Random.Seed
    , shuffledColorPatterns : List ColorPattern
    }


new : GameSize -> Random.Seed -> Game
new { halfWidth, halfHeight } seed =
    { phase = PhaseSetup
    , maybeWinnerId = Nothing
    , time = 0

    --
    , baseById = Dict.empty
    , teamById = Dict.empty
    , playerByKey = Dict.empty
    , projectileById = Dict.empty
    , unitById = Dict.empty
    , lastId = 0

    --
    , cosmetics = []
    , halfWidth = halfWidth
    , halfHeight = halfHeight
    , wallTiles = Set.empty
    , staticObstacles = Set.empty
    , dynamicObstacles = Set.empty

    --
    , seed = seed
    , shuffledColorPatterns = Random.step (Random.List.shuffle ColorPattern.patterns) seed |> Tuple.first
    }
      |> addTeam
      |> Tuple.first
      |> addTeam
      |> Tuple.first



-- Deltas


type Delta
    = DeltaNone
    | DeltaList (List Delta)
    | DeltaGame (Game -> Game)


deltaNone : Delta
deltaNone =
    DeltaNone


deltaList : List Delta -> Delta
deltaList =
    DeltaList


deltaGame : (Game -> Game) -> Delta
deltaGame =
    DeltaGame


deltaBase : Id -> (Game -> Base -> Base) -> Delta
deltaBase =
    deltaEntity .baseById updateBase


deltaTeam : Id -> (Game -> Team -> Team) -> Delta
deltaTeam =
    deltaEntity .teamById updateTeam


deltaPlayer : String -> (Game -> Player -> Player) -> Delta
deltaPlayer =
    deltaEntity .playerByKey updatePlayer


deltaUnit : Id -> (Game -> Unit -> Unit) -> Delta
deltaUnit =
    deltaEntity .unitById updateUnit


deltaProjectile : Id -> (Game -> Projectile -> Projectile) -> Delta
deltaProjectile =
    deltaEntity .projectileById updateProjectile


deltaEntity : (Game -> Dict comparable a) -> (a -> Game -> Game) -> comparable -> (Game -> a -> a) -> Delta
deltaEntity getter setter entityId updateEntity =
    let
        updateGame game =
            case Dict.get entityId (getter game) of
                Nothing ->
                    game

                Just entity ->
                    setter (updateEntity game entity) game
    in
    DeltaGame updateGame



-- Game manipulation helpers


updateBase : Base -> Game -> Game
updateBase base game =
    { game | baseById = Dict.insert base.id base game.baseById }


updateTeam : Team -> Game -> Game
updateTeam team game =
    { game | teamById = Dict.insert team.id team game.teamById }


updatePlayer : Player -> Game -> Game
updatePlayer player game =
    { game | playerByKey = Dict.insert player.inputSourceKey player game.playerByKey }


updateUnit : Unit -> Game -> Game
updateUnit unit game =
    { game | unitById = Dict.insert unit.id unit game.unitById }


updateProjectile : Projectile -> Game -> Game
updateProjectile projectile game =
    { game | projectileById = Dict.insert projectile.id projectile game.projectileById }


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


withTeam : Game -> Id -> (Team -> Game) -> Game
withTeam =
    with .teamById


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
tileDistance ( ax, ay ) ( bx, by ) =
    abs (ax - bx) + abs (ay - by) |> toFloat


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


teamColorPattern : Game -> Id -> ColorPattern
teamColorPattern game teamId =
    case Dict.get teamId game.teamById of
        Nothing ->
            ColorPattern.neutral

        Just team ->
            team.colorPattern
