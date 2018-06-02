module Init exposing (..)

import Base
import ColorPattern
import Dict exposing (Dict)
import Game exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Pathfinding
import Random
import Random.List
import Set
import SubThink


addSub : Maybe TeamId -> Vec2 -> Game -> Game
addSub maybeTeamId position game =
    Game.addSub maybeTeamId position game |> Tuple.first


addEmbeddedSub : Maybe TeamId -> Base -> Game -> Game
addEmbeddedSub maybeTeamId base game =
    let
        ( game_, unit ) =
            Game.addSub maybeTeamId (vec2 0 0) game
    in
    SubThink.deltaGameUnitEntersBase unit.id base.id game_


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


{-| Pathing cannot be initialised until all static obstacles are in place
-}
kickstartPathing : Game -> Game
kickstartPathing game =
    let
        addPathing : Team -> Team
        addPathing team =
            { team | pathing = Pathfinding.makePaths game (vec2Tile team.markerPosition) }
    in
    game
        |> updateTeam (addPathing game.leftTeam)
        |> updateTeam (addPathing game.rightTeam)



--


rect : Int -> Int -> Int -> Int -> List Tile2
rect x y w h =
    List.range x (x + w - 1)
        |> List.map
            (\xx ->
                List.range y (y + h - 1)
                    |> List.map
                        (\yy ->
                            ( xx, yy )
                        )
            )
        |> List.concat


mirror : List Tile2 -> List Tile2
mirror tiles =
    tiles
        |> List.map (\( x, y ) -> ( -x - 1, -y - 1 ))
        |> (++) tiles


walls =
    [ rect -3 -5 1 4
    , rect -10 -2 3 2
    , rect -18 7 4 3
    ]
        |> List.concat
        |> mirror


setupPhase : GameSize -> Game
setupPhase gameSize =
    Game.new gameSize (Random.initialSeed 0)
