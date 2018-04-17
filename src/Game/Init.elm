module Game.Init exposing (..)

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
        |> Game.addUnit player.id True position
        |> Tuple.first
    , player
    )


addSub : Id -> Vec2 -> Game -> Game
addSub ownerId position game =
    Game.addUnit ownerId False position game |> Tuple.first


addEmbeddedSub : Base -> Game -> Game
addEmbeddedSub base game =
    let
        ownerId =
            base.maybeOwnerId |> Maybe.withDefault -1

        ( game_, unit ) =
            Game.addUnit ownerId False (vec2 0 0) game
    in
    SubThink.deltaGameUnitEntersBase unit.id base.id game_


addSmallBase : Tile2 -> Game -> Game
addSmallBase tile game =
    let
        ( game_, base ) =
            Game.addBase BaseSmall tile game
    in
    game_
        |> addEmbeddedSub base
        |> addEmbeddedSub base
        |> addEmbeddedSub base
        |> addEmbeddedSub base


addMainBase : Id -> Tile2 -> Game -> Game
addMainBase ownerId tile game =
    let
        ( game_, base ) =
            Game.addBase BaseMain tile game
                |> Tuple.mapSecond (\b -> { b | maybeOwnerId = Just ownerId })
    in
    game_
        |> addEmbeddedSub base
        |> addEmbeddedSub base
        |> addEmbeddedSub base
        |> addEmbeddedSub base



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
