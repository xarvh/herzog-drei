module Game.Update exposing (..)

import BaseThink
import Dict exposing (Dict)
import Game exposing (..)
import List.Extra
import PlayerThink
import ProjectileThink
import Set exposing (Set)
import UnitThink
import VictoryThink
import View.Gfx


-- Main update function


update : Seconds -> List ( Controller, PlayerInput ) -> Game -> Game
update dt controllersAndInputs game =
    let
        units =
            Dict.values game.unitById

        updatedDynamicObstacles =
            units
                |> List.map (.position >> vec2Tile)
                |> Set.fromList

        oldGameWithUpdatedDynamicObstacles =
            { game | dynamicObstacles = updatedDynamicObstacles }

        getInputForPlayer player =
            case List.Extra.find (\( controller, input ) -> controller == player.controller) controllersAndInputs of
                Nothing ->
                    Game.neutralPlayerInput

                Just ( controller, input ) ->
                    input

        playerThink player =
            PlayerThink.think (getInputForPlayer player) dt oldGameWithUpdatedDynamicObstacles player
    in
    [ units
        |> List.map (UnitThink.think dt oldGameWithUpdatedDynamicObstacles)
    , game.playerById
        |> Dict.values
        |> List.map playerThink
    , game.baseById
        |> Dict.values
        |> List.map (BaseThink.think dt oldGameWithUpdatedDynamicObstacles)
    , game.projectileById
        |> Dict.values
        |> List.map (ProjectileThink.think dt oldGameWithUpdatedDynamicObstacles)
    , game
        |> VictoryThink.think dt
        |> List.singleton
    ]
        |> List.map deltaList
        |> applyGameDeltas oldGameWithUpdatedDynamicObstacles
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
