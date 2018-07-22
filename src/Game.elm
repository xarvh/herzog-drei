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


{-| TODO rename to Radians, Degrees
-}
type alias Angle =
    Float


type alias Id =
    Int


type alias InputKey =
    String


type alias Tile2 =
    ( Int, Int )



-- Validated Map


type alias ValidatedMap =
    { name : String
    , author : String
    , halfWidth : Int
    , halfHeight : Int
    , leftBase : Tile2
    , rightBase : Tile2
    , smallBases : Set Tile2
    , wallTiles : Set Tile2
    }



-- Team


type TeamId
    = TeamLeft
    | TeamRight


type alias TeamSeed =
    { mechClassByInputKey : Dict InputKey MechClass
    , colorPattern : ColorPattern
    }


type alias Team =
    { id : TeamId
    , colorPattern : ColorPattern
    , markerPosition : Vec2
    , markerTime : Seconds
    , pathing : Dict Tile2 Float
    , mechClassByInputKey : Dict InputKey MechClass
    , bigSubsToSpawn : Int
    }


getTeam : Game -> TeamId -> Team
getTeam game teamId =
    case teamId of
        TeamLeft ->
            game.leftTeam

        TeamRight ->
            game.rightTeam


maybeGetTeam : Game -> Maybe TeamId -> Maybe Team
maybeGetTeam game =
    Maybe.map (getTeam game)



-- Input


type Aim
    = AimRelative Vec2
    | AimAbsolute Vec2


type alias InputState =
    { aim : Aim

    -- Attack
    , fire : Bool

    -- Transform or change base production
    , transform : Bool

    -- Change selected units
    -- Hold: select all units
    , switchUnit : Bool

    -- Rally selected units
    -- Hold: retreat
    , rally : Bool

    -- Move
    , move : Vec2
    }


inputStateNeutral : InputState
inputStateNeutral =
    { aim = AimAbsolute (vec2 0 0)
    , fire = False
    , transform = False
    , switchUnit = False
    , rally = False
    , move = vec2 0 0
    }



-- Projectiles


type alias ProjectileSeed =
    { maybeTeamId : Maybe TeamId
    , position : Vec2
    , angle : Angle
    , classId : ProjectileClassId
    , maybeTargetId : Maybe Id
    }


type alias Projectile =
    { id : Id
    , maybeTeamId : Maybe TeamId
    , position : Vec2
    , spawnPosition : Vec2
    , spawnTime : Seconds
    , angle : Angle
    , classId : ProjectileClassId
    , maybeTargetId : Maybe Id
    }


type ProjectileClassId
    = PlaneBullet
    | BigSubBullet
    | HeliRocket
    | HeliMissile
    | UpwardSalvo
    | DownwardSalvo


type ProjectileEffect
    = ProjectileDamage Float
    | ProjectileSplashDamage { radius : Float, damage : Float }


type alias ProjectileClass =
    { speed : Float
    , range : Float
    , effect : ProjectileEffect
    , trail : Bool
    , acceleration : Float
    , travelsAlongZ : Bool
    }



-- Units


type UnitMode
    = UnitModeFree
    | UnitModeBase Id


type TransformMode
    = ToMech
    | ToFlyer


type MechClass
    = Plane
    | Heli
    | Blimp


type alias MechComponent =
    { transformState : Float
    , transformingTo : TransformMode
    , inputKey : InputKey
    , class : MechClass
    }


type alias SubComponent =
    { mode : UnitMode
    , targetId : Id
    , isBig : Bool
    }


type UnitComponent
    = UnitMech MechComponent
    | UnitSub SubComponent


type Charge
    = Charging Seconds
    | Stretching Int Seconds
    | Cooldown Seconds


type alias Unit =
    { id : Id
    , component : UnitComponent
    , maybeTeamId : Maybe TeamId
    , integrity : Float
    , position : Vec2
    , reloadEndTime : Seconds
    , maybeCharge : Maybe Charge

    --
    , fireAngle : Float
    , lookAngle : Float
    , moveAngle : Float

    --
    , isLeavingBase : Bool
    }


addUnit : UnitComponent -> Maybe TeamId -> Vec2 -> Angle -> Game -> ( Game, Unit )
addUnit component maybeTeamId position startAngle game =
    let
        id =
            game.lastId + 1

        faceCenterOfMap =
            Vec2.negate position |> vecToAngle

        unit =
            { id = id
            , component = component
            , maybeTeamId = maybeTeamId
            , integrity = 1
            , position = position
            , reloadEndTime = game.time
            , maybeCharge = Nothing

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


addSub : Maybe TeamId -> Vec2 -> Bool -> Game -> ( Game, Unit )
addSub maybeTeamId position isBig game =
    let
        { x, y } =
            Vec2.toRecord position

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

        subComponent =
            UnitSub
                { mode = UnitModeFree
                , targetId = -1
                , isBig = isBig
                }
    in
    addUnit subComponent maybeTeamId position startAngle game


addMech : MechClass -> InputKey -> Maybe TeamId -> Vec2 -> Game -> ( Game, Unit )
addMech class inputKey maybeTeamId position game =
    let
        startAngle =
            0

        mechComponent =
            UnitMech
                { transformState = 1
                , transformingTo = ToFlyer
                , inputKey = inputKey
                , class = class
                }
    in
    addUnit mechComponent maybeTeamId position startAngle game


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


deltaShake : Float -> Delta
deltaShake shake =
    deltaGame (\g -> { g | shake = g.shake + shake })



-- Bases


type BaseType
    = BaseMain
    | BaseSmall


type alias BaseOccupied =
    { maybeTeamId : Maybe TeamId
    , unitIds : Set Id
    , isActive : Bool
    , subBuildCompletion : Float
    , mechBuildCompletions : List ( MechComponent, Float )
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
    | GfxFractalBeam Vec2 Vec2 ColorPattern
    | GfxFlyingHead MechClass Vec2 Vec2 ColorPattern
    | GfxRepairBubble Vec2
    | GfxTrail Vec2 Angle Float


type alias Gfx =
    { age : Seconds
    , maxAge : Seconds
    , render : GfxRender
    }



-- Game


type GameMode
    = GameModeTeamSelection ValidatedMap
    | GameModeVersus


type GameFade
    = GameFadeIn
    | GameFadeOut


type alias Game =
    { mode : GameMode
    , maybeTransition : Maybe { start : Seconds, fade : GameFade }
    , time : Seconds
    , leftTeam : Team
    , rightTeam : Team
    , maybeWinnerTeamId : Maybe TeamId

    --
    , halfWidth : Int
    , halfHeight : Int
    , subBuildMultiplier : Float
    , wallTiles : Set Tile2

    -- deferred deltas
    , laters : List ( Seconds, SerialisedDelta )

    -- entities
    , baseById : Dict Id Base
    , projectileById : Dict Id Projectile
    , unitById : Dict Id Unit
    , lastId : Id
    , cosmetics : List Gfx

    -- includes walls and bases
    , staticObstacles : Set Tile2

    -- land units
    , dynamicObstacles : Set Tile2

    -- random, used only for cosmetics
    , seed : Random.Seed
    , shake : Float
    , shakeVector : Vec2
    }



-- Deltas


type Delta
    = DeltaNone
    | DeltaList (List Delta)
    | DeltaLater Seconds SerialisedDelta
    | DeltaGame (Game -> Game)
    | DeltaRandom (Random.Generator Delta)
    | DeltaOutcome Outcome


type Outcome
    = OutcomeCanAddBots
    | OutcomeCanInitBots


type SerialisedDelta
    = SpawnDownwardRocket { maybeTeamId : Maybe TeamId, target : Vec2 }


deltaNone : Delta
deltaNone =
    DeltaNone


deltaList : List Delta -> Delta
deltaList =
    DeltaList


deltaLater : Seconds -> SerialisedDelta -> Delta
deltaLater =
    DeltaLater


deltaGame : (Game -> Game) -> Delta
deltaGame =
    DeltaGame


deltaRandom : (a -> Delta) -> Random.Generator a -> Delta
deltaRandom function generator =
    DeltaRandom (Random.map function generator)


deltaRandom2 : (a -> b -> Delta) -> Random.Generator a -> Random.Generator b -> Delta
deltaRandom2 function generatorA generatorB =
    DeltaRandom (Random.map2 function generatorA generatorB)


deltaWithChance : Float -> Delta -> Delta
deltaWithChance chance delta =
    let
        rollToDelta : Float -> Delta
        rollToDelta roll =
            if roll > chance then
                deltaNone
            else
                delta
    in
    deltaRandom rollToDelta (Random.float 0 1)



--


deltaBase : Id -> (Game -> Base -> Base) -> Delta
deltaBase =
    deltaEntity .baseById updateBase


deltaTeam : TeamId -> (Game -> Team -> Team) -> Delta
deltaTeam teamId update =
    let
        updateGame : Game -> Game
        updateGame game =
            case teamId of
                TeamLeft ->
                    { game | leftTeam = update game game.leftTeam }

                TeamRight ->
                    { game | rightTeam = update game game.rightTeam }
    in
    DeltaGame updateGame


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


generateRandom : Random.Generator a -> Game -> ( a, Game )
generateRandom generator game =
    let
        ( value, seed ) =
            Random.step generator game.seed
    in
    ( value, { game | seed = seed } )


updateBase : Base -> Game -> Game
updateBase base game =
    { game | baseById = Dict.insert base.id base game.baseById }


updateTeam : Team -> Game -> Game
updateTeam team game =
    case team.id of
        TeamLeft ->
            { game | leftTeam = team }

        TeamRight ->
            { game | rightTeam = team }


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


withTeam : Game -> Maybe TeamId -> (Team -> Game) -> Game
withTeam game teamId fn =
    case maybeGetTeam game teamId of
        Nothing ->
            game

        Just team ->
            fn team


withUnit : Game -> Id -> (Unit -> Game) -> Game
withUnit =
    with .unitById



-- Obstacles


addStaticObstacles : List Tile2 -> Game -> Game
addStaticObstacles tiles game =
    { game | staticObstacles = Set.union (Set.fromList tiles) game.staticObstacles }



-- Seconds helpers


periodLinear : Seconds -> Float -> Seconds -> Float
periodLinear time phase period =
    let
        t =
            time + phase * period

        n =
            t / period |> floor |> toFloat
    in
    t / period - n


periodHarmonic : Seconds -> Angle -> Seconds -> Float
periodHarmonic time phase period =
    periodLinear time phase period * pi |> sin



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
        a =
            Vec2.toRecord v1

        b =
            Vec2.toRecord v2
    in
    abs (a.x - b.x) + abs (a.y - b.y)


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
        { x, y } =
            Vec2.toRecord v

        hw =
            toFloat game.halfWidth - radius

        hh =
            toFloat game.halfHeight - radius
    in
    vec2 (clamp -hw hw x) (clamp -hh hh y)


vec2Tile : Vec2 -> Tile2
vec2Tile v =
    let
        { x, y } =
            Vec2.toRecord v
    in
    ( floor x, floor y )


tile2Vec : Tile2 -> Vec2
tile2Vec ( x, y ) =
    vec2 (toFloat x) (toFloat y)


vecToAngle : Vec2 -> Float
vecToAngle v =
    let
        { x, y } =
            Vec2.toRecord v
    in
    atan2 x y


normalizeAngle : Float -> Float
normalizeAngle angle =
    let
        n =
            (angle + pi) / (2 * pi) |> floor |> toFloat
    in
    angle - n * 2 * pi


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
        { x, y } =
            Vec2.toRecord v

        sinA =
            sin -angle

        cosA =
            cos angle
    in
    vec2
        (x * cosA - y * sinA)
        (x * sinA + y * cosA)



-- Color Patterns


teamColorPattern : Game -> Maybe TeamId -> ColorPattern
teamColorPattern game teamId =
    case maybeGetTeam game teamId of
        Nothing ->
            ColorPattern.neutral

        Just team ->
            team.colorPattern
