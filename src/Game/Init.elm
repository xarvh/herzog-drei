module Game.Init exposing (..)

import ColorPattern
import Dict exposing (Dict)
import Game exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Random
import Random.List


basicGame : Game
basicGame =
    let
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

        addAiUnit : Id -> Vec2 -> Game -> Game
        addAiUnit ownerId position game =
            Game.addUnit ownerId False position game |> Tuple.first

        terrainObstacles =
            [ ( 0, 0 )
            , ( 1, 0 )
            , ( 2, 0 )
            , ( 3, 0 )
            , ( 3, 1 )
            , ( 4, 2 )
            ]

        game =
            Random.initialSeed 0
                |> Game.new
                |> Game.addBase BaseSmall ( -5, 2 )
                |> Tuple.first
                |> Game.addBase BaseSmall ( 5, -2 )
                |> Tuple.first
                |> Game.addBase BaseMain ( -16, -6 )
                |> Tuple.first
                |> Game.addBase BaseMain ( 16, 6 )
                |> Tuple.first


        ( game_, player1 ) =
            game |> addPlayerAndMech (vec2 -3 -3)

        ( game__, player2 ) =
            game_ |> addPlayerAndMech (vec2 3 3)
    in
    game__
        |> Game.addStaticObstacles terrainObstacles
        |> addAiUnit player1.id (vec2 0 -4)
        |> addAiUnit player1.id (vec2 1 -4)
        |> addAiUnit player1.id (vec2 2 -4)
        |> addAiUnit player1.id (vec2 3 -4)
        |> addAiUnit player2.id (vec2 0 4.8)
        |> addAiUnit player2.id (vec2 -1 4.8)
        |> addAiUnit player2.id (vec2 -2 4.8)
        |> addAiUnit player2.id (vec2 -3 4.8)
