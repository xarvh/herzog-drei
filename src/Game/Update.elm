module Game.Update exposing (..)

import Dict exposing (Dict)
import Game
    exposing
        ( Base
        , Delta(..)
        , Game
        , Id
        , Unit
        , UnitStatus(..)
        , normalizeAngle
        , tile2Vec
        , vec2Tile
        )
import Game.Player
import Game.Unit
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Set exposing (Set)


update : Float -> Dict Id Game.PlayerInput -> Game -> Game
update dt playerInputById oldGame =
    let
        --
        units =
            Dict.values oldGame.unitById

        updatedUnpassableTiles =
            units
                |> List.map (.position >> vec2Tile)
                |> Set.fromList
                |> Set.union oldGame.staticObstacles

        oldGameWithUpdatedUnpassableTiles =
            { oldGame | unpassableTiles = updatedUnpassableTiles }

        getInputForPlayer player =
            playerInputById
                |> Dict.get player.id
                |> Maybe.withDefault Game.neutralPlayerInput

        playerThink player =
            Game.Player.think dt oldGameWithUpdatedUnpassableTiles (getInputForPlayer player) player
    in
    List.concat
        [ units
            |> List.filterMap (Game.Unit.think dt oldGameWithUpdatedUnpassableTiles)
        , oldGame.playerById
            |> Dict.values
            |> List.map playerThink
            |> List.concat
        ]
        |> List.foldl applyGameDelta oldGameWithUpdatedUnpassableTiles


applyGameDelta : Delta -> Game -> Game
applyGameDelta delta game =
    case delta of
        MoveUnit unitId dx ->
            case Dict.get unitId game.unitById of
                Nothing ->
                    game

                Just unit ->
                    let
                        newPosition =
                            Vec2.add unit.position dx

                        currentTilePosition =
                            vec2Tile unit.position

                        newTilePosition =
                            vec2Tile newPosition
                    in
                    if currentTilePosition /= newTilePosition && Set.member newTilePosition game.unpassableTiles then
                        -- destination tile occupied, don't move
                        game
                    else
                        -- destination tile available, mark it as occupied and move unit
                        let
                            targetHeading =
                                Game.vecToAngle dx

                            deltaHeading =
                                targetHeading - unit.movementAngle |> normalizeAngle

                            maxTurn =
                                0.1

                            clampedDeltaAngle =
                                clamp -maxTurn maxTurn deltaHeading

                            newHeading =
                                unit.movementAngle + clampedDeltaAngle |> normalizeAngle

                            newUnit =
                                { unit | position = newPosition, movementAngle = newHeading }

                            unitById =
                                Dict.insert unitId newUnit game.unitById

                            unpassableTiles =
                                Set.insert newTilePosition game.unpassableTiles
                        in
                        { game | unitById = unitById, unpassableTiles = unpassableTiles }

        UnitEntersBase unitId baseId ->
            case ( Dict.get unitId game.unitById, Dict.get baseId game.baseById ) of
                ( Just unit, Just base ) ->
                    deltaUnitEntersBase unit base game

                ( _, _ ) ->
                    game

        MovePlayer playerId dp ->
            Game.Player.move playerId dp game

        RepositionMarker playerId newPosition ->
            case Dict.get playerId game.playerById of
                Nothing ->
                    game

                Just player ->
                    { game | playerById = Dict.insert playerId { player | markerPosition = newPosition } game.playerById }



-- Deltas


deltaUnitEntersBase : Unit -> Base -> Game -> Game
deltaUnitEntersBase unit base game =
    if base.maybeOwnerId /= Nothing && base.maybeOwnerId /= Just unit.ownerId then
        game
    else
        let
            corners =
                Game.baseCorners base

            unitsInBase =
                game.unitById
                    |> Dict.values
                    |> List.filter (\u -> u.status == UnitStatusInBase base.id)

            takenCorners =
                unitsInBase
                    |> List.map .position
        in
        case List.Extra.find (\c -> not (List.member c takenCorners)) corners of
            Nothing ->
                game

            Just corner ->
                let
                    containedUnits =
                        1 + List.length takenCorners

                    newUnit =
                        { unit
                            | status = Game.UnitStatusInBase base.id
                            , position = corner
                        }

                    newBase =
                        { base
                            | containedUnits = containedUnits
                            , isActive = base.isActive || containedUnits == List.length corners
                            , maybeOwnerId = Just unit.ownerId
                        }
                in
                { game
                    | unitById = Dict.insert unit.id newUnit game.unitById
                    , baseById = Dict.insert base.id newBase game.baseById
                }
