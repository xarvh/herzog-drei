module Game.Update exposing (..)

import Dict exposing (Dict)
import Game.Player
import Game exposing (Delta(..), Game, vec2Tile)
import Game.Unit
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Set exposing (Set)


update : Float -> Vec2 -> Game -> Game
update dt movement oldGame =
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
    in
    List.concat
        [ List.filterMap (Game.Unit.think dt oldGameWithUpdatedUnpassableTiles) units
        -- TODO movement should depend on the input method
        , List.filterMap (Game.Player.think dt movement oldGameWithUpdatedUnpassableTiles) (Dict.values oldGame.playerById)
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
                    if base.containedUnits < 4 then
                        let
                            unitById =
                                Dict.remove unit.id game.unitById

                            baseById =
                                Dict.insert base.id { base | containedUnits = base.containedUnits + 1 } game.baseById
                        in
                        { game | unitById = unitById, baseById = baseById }
                    else
                        game

                ( _, _ ) ->
                    game

        MovePlayer playerId dp ->
            Game.Player.move playerId dp game
