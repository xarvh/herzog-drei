module Game.Update exposing (..)

import BaseThink
import Dict exposing (Dict)
import Game exposing (..)
import PlayerThink
import ProjectileThink
import Set exposing (Set)
import UnitThink
import VictoryThink
import View.Gfx


-- Main update function


update : Seconds -> Dict Id Game.PlayerInput -> Game -> Game
update dt playerInputById game =
    let
        units =
            Dict.values game.unitById

        updatedUnpassableTiles =
            units
                |> List.map (.position >> vec2Tile)
                |> Set.fromList
                |> Set.union game.staticObstacles

        oldGameWithUpdatedUnpassableTiles =
            { game | unpassableTiles = updatedUnpassableTiles }

        getInputForPlayer player =
            playerInputById
                |> Dict.get player.id
                |> Maybe.withDefault Game.neutralPlayerInput

        playerThink player =
            PlayerThink.think (getInputForPlayer player) dt oldGameWithUpdatedUnpassableTiles player
    in
    [ units
        |> List.map (UnitThink.think dt oldGameWithUpdatedUnpassableTiles)
    , game.playerById
        |> Dict.values
        |> List.map playerThink
    , game.baseById
        |> Dict.values
        |> List.map (BaseThink.think dt oldGameWithUpdatedUnpassableTiles)
    , game.projectileById
        |> Dict.values
        |> List.map (ProjectileThink.think dt oldGameWithUpdatedUnpassableTiles)
    , game
        |> VictoryThink.think dt
        |> List.singleton
    ]
        |> List.map deltaList
        |> applyGameDeltas oldGameWithUpdatedUnpassableTiles
        |> updateGfxs dt



-- Gfxs


updateGfxs : Seconds -> Game -> Game
updateGfxs dt game =
    { game | cosmetics = List.filterMap (View.Gfx.update dt) game.cosmetics }



-- Folder


applyDelta : Delta -> Game -> Game
applyDelta delta game =
    case delta of
        DeltaNone ->
            game

        DeltaList list ->
            List.foldl applyDelta game list

        DeltaGame f ->
            f game


applyGameDeltas : Game -> List Delta -> Game
applyGameDeltas game deltas =
    List.foldl applyDelta game deltas
