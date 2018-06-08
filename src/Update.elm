module Update exposing (..)

import BaseThink
import Dict exposing (Dict)
import Game exposing (..)
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Phases
import ProjectileThink
import Set exposing (Set)
import UnitThink
import VictoryThink
import View.Gfx


-- Main update function


update : Seconds -> Dict String ( InputState, InputState ) -> Game -> Game
update time pairedInputStatesByKey game =
    let
        -- Cap dt to 0.1 secs to avoid time integration problems
        dt =
            time - game.time |> min 0.1

        units =
            Dict.values game.unitById

        updatedDynamicObstacles =
            units
                |> List.map (.position >> vec2Tile)
                |> Set.fromList

        oldGameWithUpdatedDynamicObstacles =
            { game | dynamicObstacles = updatedDynamicObstacles }
    in
    [ units
        |> List.map (UnitThink.think dt pairedInputStatesByKey oldGameWithUpdatedDynamicObstacles)
    , [ case game.phase of
            PhaseSetup ->
                Phases.setupThink (Dict.keys pairedInputStatesByKey) game

            PhasePlay ->
                VictoryThink.think dt game
      ]
    , game.baseById
        |> Dict.values
        |> List.map (BaseThink.think dt oldGameWithUpdatedDynamicObstacles)
    , game.projectileById
        |> Dict.values
        |> List.map (ProjectileThink.think dt oldGameWithUpdatedDynamicObstacles)
    ]
        |> List.map deltaList
        |> applyGameDeltas oldGameWithUpdatedDynamicObstacles
        |> updateGfxs dt
        |> Phases.transitionUpdate dt
        |> (\game -> { game | time = time })



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
