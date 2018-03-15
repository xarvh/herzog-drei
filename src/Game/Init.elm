module Game.Init exposing (..)

import ColorPattern
import Dict exposing (Dict)
import Game exposing (Game)
import Game.Base
import Game.Player
import Game.Unit
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Random
import Random.List
import Set exposing (Set)


init : Random.Seed -> Game
init seed =
    let
        shuffledColorPatterns =
            Random.step (Random.List.shuffle ColorPattern.patterns) seed |> Tuple.first

        playerById =
            Dict.empty
                |> Game.Player.add shuffledColorPatterns 10 (vec2 -3 -3)

        baseById =
            Dict.empty
                |> Game.Base.add 99 ( 0, 0 )

        unitById =
            Dict.empty
                |> Game.Unit.add 0 0 (vec2 -2 -5)
                |> Game.Unit.add 1 0 (vec2 2 -4.1)
                |> Game.Unit.add 2 0 (vec2 2 -4.2)
                |> Game.Unit.add 3 0 (vec2 2 -4.3)
                |> Game.Unit.add 4 0 (vec2 2 -4.11)
                |> Game.Unit.add 5 0 (vec2 2 -4.3)
                |> Game.Unit.add 6 0 (vec2 2 -4.02)

        terrainObstacles =
            [ ( 0, 0 )
            , ( 1, 0 )
            , ( 2, 0 )
            , ( 3, 0 )
            , ( 3, 1 )
            , ( 4, 2 )
            ]
                |> Set.fromList

        staticObstacles =
            baseById
                |> Dict.values
                |> List.map Game.Base.tiles
                |> List.foldl Set.union terrainObstacles
    in
    { baseById = baseById
    , unitById = unitById
    , playerById = playerById

    --
    , staticObstacles = staticObstacles
    , unpassableTiles = Set.empty

    --
    , seed = seed
    , shuffledColorPatterns = shuffledColorPatterns
    }
