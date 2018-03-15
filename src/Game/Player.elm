module Game.Player exposing (..)

import ColorPattern exposing (ColorPattern)
import Dict exposing (Dict)
import Game
    exposing
        ( Delta(..)
        , Game
        , Id
        , Player
        , tile2Vec
        , vec2Tile
        )
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Set exposing (Set)


add : List ColorPattern -> Id -> Vec2 -> Dict Id Player -> Dict Id Player
add shuffledColorPatterns id position playerById =
    let
        colorPatternCount colorPattern =
            playerById
                |> Dict.values
                |> List.filter (\player -> player.colorPattern == colorPattern)
                |> List.length

        colorPattern =
            shuffledColorPatterns
                |> List.sortBy colorPatternCount
                |> List.head
                |> Maybe.withDefault ColorPattern.neutral
    in
    Dict.insert
        id
        { id = id
        , position = position
        , markerPosition = position
        , colorPattern = colorPattern
        }
        playerById


think : Float -> Vec2 -> Game -> Player -> Maybe Delta
think dt movement game player =
    let
        speed =
            2

        dx =
            Vec2.scale (speed * dt / 1000) movement
    in
    MovePlayer player.id dx |> Just


move : Id -> Vec2 -> Game -> Game
move playerId dp game =
    case Dict.get playerId game.playerById of
        Nothing ->
            game

        Just player ->
            let
                isObstacle tile =
                    Set.member tile game.staticObstacles

                originalPosition =
                    player.position

                originalTile =
                    vec2Tile originalPosition

                idealPosition =
                    Vec2.add originalPosition dp

                idealTile =
                    vec2Tile idealPosition

                didNotChangeTile =
                    idealTile == originalTile

                idealPositionIsObstacle =
                    isObstacle idealTile
            in
            if didNotChangeTile || not idealPositionIsObstacle then
                { game | playerById = Dict.insert playerId { player | position = idealPosition } game.playerById }
            else
                let
                    ( tX, tY ) =
                        originalTile

                    leftTile =
                        ( tX - 1, tY )

                    rightTile =
                        ( tX + 1, tY )

                    topTile =
                        ( tX, tY + 1 )

                    bottomTile =
                        ( tX, tY - 1 )

                    oX =
                        toFloat tX

                    oY =
                        toFloat tY

                    minX =
                        if isObstacle leftTile then
                            oX
                        else
                            oX - 1

                    maxX =
                        if isObstacle rightTile then
                            oX + 0.99
                        else
                            oX + 1.99

                    minY =
                        if isObstacle bottomTile then
                            oY
                        else
                            oY - 1

                    maxY =
                        if isObstacle topTile then
                            oY + 0.99
                        else
                            oY + 1.99

                    ( iX, iY ) =
                        Vec2.toTuple idealPosition

                    fX =
                        clamp minX maxX iX

                    fY =
                        clamp minY maxY iY
                in
                { game | playerById = Dict.insert playerId { player | position = vec2 fX fY } game.playerById }
