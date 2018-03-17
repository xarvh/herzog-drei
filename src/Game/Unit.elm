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
        , UnitStatus(..)
        , clampToRadius
        , tile2Vec
        , tileDistance
        , vec2Tile
        , vectorDistance
        )
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Set exposing (Set)


add : Id -> Vec2 -> Game -> ( Game, Unit )
add ownerId position game =
    let
        id =
            game.lastId + 1

        unit =
            { id = id
            , ownerId = ownerId
            , order = UnitOrderFollowMarker
            , status = Game.UnitStatusFree
            , position = position
            }

        unitById =
            Dict.insert id unit game.unitById
    in
    ( { game | lastId = id, unitById = unitById }, unit )


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
    case unit.status of
        UnitStatusInBase baseId ->
            Nothing

        UnitStatusFree ->
            case unit.order of
                UnitOrderStay ->
                    Nothing

                UnitOrderEnterBase baseId ->
                    case Dict.get baseId game.baseById of
                        Nothing ->
                            Nothing

                        Just base ->
                            if vectorDistance unit.position (tile2Vec base.position) > Game.maximumDistanceForUnitToEnterBase then
                                move dt game (tile2Vec base.position) unit
                            else
                                Just (UnitEntersBase unit.id base.id)

                UnitOrderMoveTo targetPosition ->
                    move dt game targetPosition unit

                {-
                   Movement:
                     if base nearby && can be entered -> move / enter
                     else -> move to marker
                -}
                UnitOrderFollowMarker ->
                    case Dict.get unit.ownerId game.playerById of
                        Nothing ->
                            Nothing

                        Just player ->
                            let
                                conquerBaseDistanceThreshold =
                                    3.0

                                baseDistance base =
                                    vectorDistance (tile2Vec base.position) unit.position

                                baseIsConquerable base =
                                    baseDistance base
                                        < conquerBaseDistanceThreshold
                                        && (base.maybeOwnerId == Nothing || base.maybeOwnerId == Just unit.ownerId)
                                        && (base.containedUnits < Game.baseMaxContainedUnits)
                            in
                            case List.Extra.find baseIsConquerable (Dict.values game.baseById) of
                                Just base ->
                                    if baseDistance base > Game.maximumDistanceForUnitToEnterBase then
                                        move dt game (tile2Vec base.position) unit
                                    else
                                        Just (UnitEntersBase unit.id base.id)

                                Nothing ->
                                    move dt game player.markerPosition unit
