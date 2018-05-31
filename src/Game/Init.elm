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


addSub : Id -> Vec2 -> Game -> Game
addSub teamId position game =
    Game.addSub teamId position game |> Tuple.first


addEmbeddedSub : Id -> Base -> Game -> Game
addEmbeddedSub teamId base game =
    let
        ( game_, unit ) =
            Game.addSub teamId (vec2 0 0) game
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
addMainBase teamId tile game =
    let
        ( game_, base ) =
            Base.add BaseMain tile game
    in
    game_
        |> addEmbeddedSub teamId base
        |> addEmbeddedSub teamId base
        |> addEmbeddedSub teamId base
        |> addEmbeddedSub teamId base


{-| Pathing cannot be initialised until all static obstacles are in place
-}
kickstartPathing : Game -> Game
kickstartPathing game =
    let
        addPathing : Id -> Team -> Team
        addPathing id team =
            { team | pathing = Pathfinding.makePaths game (vec2Tile team.markerPosition) }
    in
    { game | teamById = Dict.map addPathing game.teamById }



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


basicGame : GameSize -> List String -> List String -> Game
basicGame gameSize inputSourcesTeam1 inputSourcesTeam2 =
    let
        walls =
            [ rect -3 -5 1 4
            , rect -10 -2 3 2
            , rect -18 7 4 3
            ]
                |> List.concat
                |> mirror

        game =
            Game.new gameSize (Random.initialSeed 0)
    in
    { game | wallTiles = Set.fromList walls }
        |> Game.addStaticObstacles walls
        |> addSmallBase ( -5, 2 )
        |> addSmallBase ( 5, -2 )
--         |> addMainBase team1.id ( -16, -6 )
--         |> addMainBase team2.id ( 16, 6 )
        |> kickstartPathing



--


setupPhase : GameSize -> Game
setupPhase gameSize =
    Game.new gameSize (Random.initialSeed 0)
