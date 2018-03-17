module Game.Unit exposing (..)

import AStar
import Dict exposing (Dict)
import Game
    exposing
        ( Delta(..)
        , Game
        , Id
        , Tile2
        , Unit
        , UnitOrder(..)
        , clampToRadius
        , tile2Vec
        , tileDistance
        , vec2Tile
        , vectorDistance
        )
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Set exposing (Set)


add : Id -> Id -> Vec2 -> Dict Id Unit -> Dict Id Unit
add id ownerId position =
    Dict.insert
        id
        { id = id
        , ownerId = ownerId
        , order = UnitOrderFollowMarker
        , position = position
        }


getAvailableMoves : Set Tile2 -> Tile2 -> Set Tile2
getAvailableMoves occupiedPositions ( x, y ) =
    [ if x > -5 then
        [ ( x - 1, y ) ]
      else
        []
    , if x < 4 then
        [ ( x + 1, y ) ]
      else
        []
    , if y > -5 then
        [ ( x, y - 1 ) ]
      else
        []
    , if y < 4 then
        [ ( x, y + 1 ) ]
      else
        []
    ]
        |> List.concat
        |> List.filter (\pos -> not <| Set.member pos occupiedPositions)
        |> Set.fromList


move : Float -> Game -> Vec2 -> Unit -> Maybe Delta
move dt game targetPosition unit =
    let
        targetDistance =
            0
    in
    if vectorDistance unit.position targetPosition <= targetDistance then
        Nothing
    else
        let
            unitTile =
                vec2Tile unit.position

            path =
                AStar.findPath
                    tileDistance
                    (getAvailableMoves game.unpassableTiles)
                    unitTile
                    (vec2Tile targetPosition)
                    targetDistance

            idealDelta =
                case path of
                    [] ->
                        Vec2.sub targetPosition unit.position

                    head :: tail ->
                        Vec2.sub (tile2Vec head) (tile2Vec unitTile)

            speed =
                1

            maxLength =
                speed * dt / 1000

            viableDelta =
                clampToRadius maxLength idealDelta
        in
        Just (MoveUnit unit.id viableDelta)


think : Float -> Game -> Unit -> Maybe Delta
think dt game unit =
    case unit.order of
        UnitOrderStay ->
            Nothing

        UnitOrderEnterBase baseId ->
            case Dict.get baseId game.baseById of
                Nothing ->
                    Nothing

                Just base ->
                    if vectorDistance unit.position (tile2Vec base.position) > 2.1 then
                        move dt game (tile2Vec base.position) unit
                    else
                        Just (UnitEntersBase unit.id base.id)

        UnitOrderMoveTo targetPosition ->
            move dt game targetPosition unit

        UnitOrderFollowMarker ->
            case Dict.get unit.ownerId game.playerById of
                Nothing ->
                    Nothing

                Just player ->
                    move dt game player.markerPosition unit
