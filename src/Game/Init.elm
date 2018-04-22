module Game.Init exposing (..)

import Base
import ColorPattern
import Dict exposing (Dict)
import Game exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Random
import Random.List
import Set
import SubThink


{-

   type GameInsert a
       = GameInsert (Game -> ( a, Game ))


   andThen : (a -> GameInsert b) -> GameInsert a -> GameInsert b
   andThen callback (GameInsert insertA) =
       GameInsert <|
           \game ->
               let
                   ( result, newGame ) =
                       insertA game

                   (GameInsert insertB) =
                       callback result
               in
               insertB game



   insertAll : GameInsert a -> Game -> ( a, Game )
   insertAll (GameInsert gameInsert) game =
               gameInsert game


-}
--


addPlayerAndMech : Vec2 -> Game -> ( Game, Player )
addPlayerAndMech position game =
    let
        ( game_, player ) =
            Game.addPlayer position game
    in
    ( game_
        |> Game.addMech player.id position
        |> Tuple.first
    , player
    )


addSub : Id -> Vec2 -> Game -> Game
addSub ownerId position game =
    Game.addSub ownerId position game |> Tuple.first


addEmbeddedSub : Id -> Base -> Game -> Game
addEmbeddedSub playerId base game =
    let
        ( game_, unit ) =
            Game.addSub playerId (vec2 0 0) game
    in
    SubThink.deltaGameUnitEntersBase unit.id base.id game_


addSmallBase : Tile2 -> Game -> Game
addSmallBase tile game =
    let
        ( game_, base ) =
            Base.add BaseSmall tile game
    in
    game_
        |> addEmbeddedSub -1 base
        |> addEmbeddedSub -1 base
        |> addEmbeddedSub -1 base
        |> addEmbeddedSub -1 base


addMainBase : Id -> Tile2 -> Game -> Game
addMainBase ownerId tile game =
    let
        ( game_, base ) =
            Base.add BaseMain tile game
    in
    game_
        |> addEmbeddedSub ownerId base
        |> addEmbeddedSub ownerId base
        |> addEmbeddedSub ownerId base
        |> addEmbeddedSub ownerId base



--


basicGame : Game
basicGame =
    let
        walls =
            [ ( 0, 0 )
            , ( 1, 0 )
            , ( 2, 0 )
            , ( 3, 0 )
            , ( 3, 1 )
            , ( 4, 2 )
            ]

        game =
            Random.initialSeed 0 |> Game.new

        ( game_, player1 ) =
            game |> addPlayerAndMech (vec2 -12 -4)

        ( game__, player2 ) =
            game_ |> addPlayerAndMech (vec2 12 4)
    in
    { game__ | wallTiles = Set.fromList walls }
        |> Game.addStaticObstacles walls
        |> addSmallBase ( -5, 2 )
        |> addSmallBase ( 5, -2 )
        |> addMainBase player1.id ( -16, -6 )
        |> addMainBase player2.id ( 16, 6 )
