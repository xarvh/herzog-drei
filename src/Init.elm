module Init exposing (..)

import Base
import ColorPattern exposing (ColorPattern)
import Dict exposing (Dict)
import Game exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Mech
import Pathfinding
import Random
import Set exposing (Set)
import SubThink


-- Init team selection phase


asTeamSelection : Random.Seed -> ValidatedMap -> Game
asTeamSelection seed map =
    let
        time =
            0

        ( leftTeamColor, rightTeamColor ) =
            Random.step ColorPattern.twoDifferent seed |> Tuple.first
    in
    { mode = GameModeTeamSelection map
    , maybeTransition = Just { start = time, fade = GameFadeIn }
    , time = time
    , leftTeam = newTeam TeamLeft leftTeamColor Dict.empty
    , rightTeam = newTeam TeamRight rightTeamColor Dict.empty
    , maybeWinnerTeamId = Nothing

    --
    , halfWidth = map.halfWidth
    , halfHeight = map.halfHeight
    , subBuildMultiplier = 1
    , wallTiles = Set.empty

    -- entities
    , baseById = Dict.empty
    , projectileById = Dict.empty
    , unitById = Dict.empty
    , lastId = 0
    , cosmetics = []

    -- includes walls and bases
    , staticObstacles = Set.empty

    -- land units
    , dynamicObstacles = Set.empty

    -- random, used only for cosmetics
    , seed = seed
    }



-- Init normal game


asVersus : Random.Seed -> Seconds -> TeamSeed -> TeamSeed -> ValidatedMap -> Game
asVersus randomSeed time leftTeam rightTeam map =
    let
        team id teamSeed =
            newTeam id teamSeed.colorPattern teamSeed.mechClassByInputKey
    in
    { mode = GameModeVersus
    , maybeTransition = Just { start = time, fade = GameFadeIn }
    , time = time
    , leftTeam = team TeamLeft leftTeam
    , rightTeam = team TeamRight rightTeam
    , maybeWinnerTeamId = Nothing

    --
    , halfWidth = map.halfWidth
    , halfHeight = map.halfHeight
    , subBuildMultiplier = 2
    , wallTiles = map.wallTiles

    -- entities
    , baseById = Dict.empty
    , projectileById = Dict.empty
    , unitById = Dict.empty
    , lastId = 0
    , cosmetics = []

    -- includes walls and bases
    , staticObstacles = map.wallTiles

    -- land units
    , dynamicObstacles = Set.empty

    -- random, used only for cosmetics
    , seed = randomSeed
    }
        |> (\g -> Set.foldl addSmallBase g map.smallBases)
        |> addMainBase (Just TeamLeft) map.leftBase
        |> addMainBase (Just TeamRight) map.rightBase
        |> initMarkerPosition TeamLeft
        |> initMarkerPosition TeamRight
        |> initPathing
        |> addMechForEveryPlayer


asVersusFromTeamSelection : ValidatedMap -> Game -> Game
asVersusFromTeamSelection map game =
    let
        team t =
            { colorPattern = t.colorPattern
            , mechClassByInputKey = t.mechClassByInputKey
            }
    in
    asVersus game.seed game.time (team game.leftTeam) (team game.rightTeam) map



-- Teams


newTeam : TeamId -> ColorPattern -> Dict InputKey MechClass -> Team
newTeam id colorPattern mechs =
    { id = id
    , colorPattern = colorPattern
    , markerPosition = vec2 0 0
    , markerTime = 0
    , pathing = Dict.empty
    , mechClassByInputKey = mechs
    , bigSubsToSpawn = 0
    }


initMarkerPosition : TeamId -> Game -> Game
initMarkerPosition id game =
    case Base.teamMainBase game (Just id) of
        Nothing ->
            game

        Just base ->
            let
                markerPosition =
                    base.position
                        |> Vec2.negate
                        |> Vec2.normalize
                        |> Vec2.scale 5
                        |> Vec2.add base.position

                team =
                    getTeam game id
            in
            updateTeam { team | markerPosition = markerPosition } game



-- Units


addEmbeddedSub : Maybe TeamId -> Base -> Game -> Game
addEmbeddedSub maybeTeamId base game =
    let
        ( game_, unit ) =
            Game.addSub maybeTeamId (vec2 0 0) False game
    in
    SubThink.deltaGameUnitEntersBase unit.id base.id game_



-- Bases


addSmallBase : Tile2 -> Game -> Game
addSmallBase tile game =
    let
        ( game_, base ) =
            Base.add BaseSmall tile game
    in
    game_
        |> addEmbeddedSub Nothing base
        |> addEmbeddedSub Nothing base
        |> addEmbeddedSub Nothing base
        |> addEmbeddedSub Nothing base


addMainBase : Maybe TeamId -> Tile2 -> Game -> Game
addMainBase maybeTeamId tile game =
    let
        ( game_, base ) =
            Base.add BaseMain tile game
    in
    game_
        |> addEmbeddedSub maybeTeamId base
        |> addEmbeddedSub maybeTeamId base
        |> addEmbeddedSub maybeTeamId base
        |> addEmbeddedSub maybeTeamId base



-- Mechs


addMechForEveryPlayer : Game -> Game
addMechForEveryPlayer game =
    game
        |> addMechsForTeam game.leftTeam
        |> addMechsForTeam game.rightTeam


addMechsForTeam : Team -> Game -> Game
addMechsForTeam team game =
    case Base.teamMainBase game (Just team.id) of
        Nothing ->
            game

        Just base ->
            Dict.foldl (\key class g -> Game.addMech class key (Just team.id) base.position g |> Tuple.first) game team.mechClassByInputKey



-- Pathing


{-| Pathing cannot be initialised until all static obstacles are in place
-}
initPathing : Game -> Game
initPathing game =
    let
        addPathing : Team -> Team
        addPathing team =
            { team | pathing = Pathfinding.makePaths game (vec2Tile team.markerPosition) }
    in
    game
        |> updateTeam (addPathing game.leftTeam)
        |> updateTeam (addPathing game.rightTeam)
