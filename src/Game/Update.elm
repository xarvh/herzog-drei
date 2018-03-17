module Game.Update exposing (..)

import Dict exposing (Dict)
import Game
    exposing
        ( Delta(..)
        , Game
        , Id
        , vec2Tile
        , tile2Vec
        )
import Game.Player
import Game.Unit
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
                        { game
                            | unitById = game.unitById |> Dict.insert unitId { unit | position = newPosition }
                            , unpassableTiles = game.unpassableTiles |> Set.insert newTilePosition
                        }

        UnitEntersBase unitId baseId ->
            case ( Dict.get unitId game.unitById, Dict.get baseId game.baseById ) of
                ( Just unit, Just base ) ->
                    if base.containedUnits >= Game.baseMaxContainedUnits then
                        game
                    else
                        let
                            containedUnits =
                                base.containedUnits + 1

                            newUnit =
                                { unit
                                    | status = Game.UnitStatusInBase baseId
                                    -- TODO: lay units at the base corners
                                    , position = tile2Vec base.position
                                }

                            newBase =
                                { base
                                    | containedUnits = containedUnits
                                    , isActive = base.isActive || containedUnits == Game.baseMaxContainedUnits
                                    , maybeOwnerId = Just unit.ownerId
                                }
                        in
                        { game
                            | unitById = Dict.insert unitId newUnit game.unitById
                            , baseById = Dict.insert baseId newBase game.baseById
                        }

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
