module Game.Update exposing (..)

import BaseThink
import Dict exposing (Dict)
import Game exposing (..)
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import PlayerThink
import ProjectileThink
import Set exposing (Set)
import UnitThink
import VictoryThink
import View.Gfx


-- Main update function


update : Seconds -> Dict String PlayerInput -> Game -> Game
update time playerInputBySourceId game =
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

        getInputForPlayer player =
            Dict.get player.inputSourceKey playerInputBySourceId |> Maybe.withDefault Game.neutralPlayerInput

        playerThink player =
            PlayerThink.think (getInputForPlayer player) dt game player
    in
    [ units
        |> List.map (UnitThink.think dt oldGameWithUpdatedDynamicObstacles)
    , game.playerByKey
        |> Dict.values
        |> List.map playerThink
    , [ if isSetupPhase game then
            addAndRemovePlayers playerInputBySourceId game
        else
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
        |> (\game -> { game | time = time })



-- Setup Phase


addPlayer : String -> Delta
addPlayer inputSourceKey =
    deltaGame <|
        \g ->
            let
                startingPosition =
                    vec2 0 0

                player =
                    { inputSourceKey = inputSourceKey
                    , teamId = -1
                    , viewportPosition = startingPosition
                    }
            in
            { g
                | playerByKey = Dict.insert inputSourceKey player g.playerByKey
            }
                |> addMech inputSourceKey -1 startingPosition
                |> Tuple.first


removePlayer : String -> Delta
removePlayer inputSourceKey =
    deltaNone


addAndRemovePlayers : Dict String PlayerInput -> Game -> Delta
addAndRemovePlayers playerInputBySourceId game =
    let
        inputs =
            Dict.keys playerInputBySourceId |> Set.fromList

        players =
            Dict.keys game.playerByKey |> Set.fromList

        -- ensure that there is a player for any input
        inputsWithoutPlayer =
            Set.diff inputs players |> Set.toList

        -- remove players without input
        playersWithoutInput =
            Set.diff players inputs |> Set.toList

        -- think players with input
        playersWithInput =
            Set.intersect players inputs |> Set.toList
    in
    [ List.map addPlayer inputsWithoutPlayer
    , List.map removePlayer playersWithoutInput
    ]
        |> List.map deltaList
        |> deltaList



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
