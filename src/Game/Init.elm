module Game.Init exposing (..)

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


addPlayerAndMech : Controller -> Vec2 -> Game -> ( Game, Player )
addPlayerAndMech controller position game =
    let
        ( game_, player ) =
            Game.addPlayer controller position game
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


{-| Pathing cannot be initialised until all static obstacles are in place
-}
kickstartPathing : Game -> Game
kickstartPathing game =
    let
        addPathing : Id -> Player -> Player
        addPathing id player =
            { player | pathing = Pathfinding.makePaths game (vec2Tile player.markerPosition) }
    in
    { game | playerById = Dict.map addPathing game.playerById }



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



--


basicGame : Game
basicGame =
    let
        walls =
            [ rect -3 -5 1 4
            , rect -10 -2 3 2
            , rect -18 7 4 3
            ]
                |> List.concat
                |> mirror

        game =
            Random.initialSeed 0 |> Game.new

        ( game_, player1 ) =
            game |> addPlayerAndMech ControllerPlayer (vec2 -12 -3)

        ( game__, player2 ) =
            game_ |> addPlayerAndMech ControllerBot (vec2 12 3)
    in
    { game__ | wallTiles = Set.fromList walls }
        |> Game.addStaticObstacles walls
        |> addSmallBase ( -5, 2 )
        |> addSmallBase ( 5, -2 )
        |> addMainBase player1.id ( -16, -6 )
        |> addMainBase player2.id ( 16, 6 )
        |> kickstartPathing
