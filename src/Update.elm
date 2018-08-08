module Update exposing (..)

import BaseThink
import Dict exposing (Dict)
import Game exposing (..)
import Init
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import MechThink
import ProjectileThink
import Random
import Set exposing (Set)
import SetupPhase
import UnitThink
import View.Gfx


-- Main update function


update : Seconds -> Dict String ( InputState, InputState ) -> Game -> ( Game, List Outcome )
update uncappedDt pairedInputStatesByKey oldGame =
    let
        -- Cap dt to 0.1 secs to avoid time integration problems
        dt =
            oldGame.timeMultiplier * min 0.1 uncappedDt

        newTime =
            oldGame.time + dt

        ( latersToExecute, latersToStore ) =
            List.partition (\( scheduledTime, delta ) -> scheduledTime < newTime) oldGame.laters

        units =
            Dict.values oldGame.unitById

        tempGame =
            { oldGame
                | time = newTime
                , laters = latersToStore
                , cosmetics = List.filter (\c -> newTime < c.removeTime) oldGame.cosmetics
                , dynamicObstacles =
                    units
                        |> List.map (.position >> vec2Tile)
                        |> Set.fromList
            }
    in
    [ latersToExecute
        |> List.map Tuple.second
    , units
        |> List.map (UnitThink.think dt pairedInputStatesByKey tempGame)

    --
    , [ case tempGame.mode of
            GameModeTeamSelection _ ->
                SetupPhase.think (Dict.keys pairedInputStatesByKey) tempGame

            GameModeVersus ->
                deltaNone
      ]

    --
    , [ transitionThink tempGame
      , deltaGame (screenShake dt)
      , deltaGame (slowMotion dt)
      ]

    --
    , tempGame.baseById
        |> Dict.values
        |> List.map (BaseThink.think dt tempGame)
    , tempGame.projectileById
        |> Dict.values
        |> List.map (ProjectileThink.think dt tempGame)
    ]
        |> List.map deltaList
        |> applyGameDeltas tempGame


slowMotion : Seconds -> Game -> Game
slowMotion dt game =
    let
        targetMultiplier =
            0.2

        -- This is in slowed, in-game time
        timeToReachTarget =
            0.3

        dm =
            (1 - targetMultiplier) * dt / timeToReachTarget

        timeMultiplier =
            if game.time > game.slowMotionEnd then
                min (game.timeMultiplier + dm) 1
            else
                max (game.timeMultiplier - dm) targetMultiplier
    in
    { game | timeMultiplier = timeMultiplier }


screenShake : Seconds -> Game -> Game
screenShake dt game =
    let
        removeDecimals n =
            if n < 0.0001 then
                0
            else
                n

        shake =
            game.shake * 0.2 ^ dt |> removeDecimals |> min 5

        float =
            Random.float -shake shake

        vecgen =
            Random.map2 vec2 float float

        ( v, seed ) =
            Random.step vecgen game.seed
    in
    { game | seed = seed, shakeVector = v, shake = shake }



-- Stage Transition


transitionDuration : Float
transitionDuration =
    1.0


transitionThink : Game -> Delta
transitionThink game =
    case game.maybeTransition of
        Nothing ->
            deltaNone

        Just { start, fade } ->
            if game.time - start < transitionDuration then
                deltaNone
            else
                case fade of
                    GameFadeIn ->
                        -- transitions complete
                        deltaGame (\g -> { g | maybeTransition = Nothing })

                    GameFadeOut ->
                        case game.mode of
                            GameModeTeamSelection map ->
                                -- Switch to Versus mode
                                deltaList
                                    [ deltaGame (Init.asVersusFromTeamSelection map)
                                    , DeltaOutcome OutcomeCanInitBots
                                    ]

                            GameModeVersus ->
                                deltaNone



-- Folder


applyDelta : Delta -> ( Game, List Outcome ) -> ( Game, List Outcome )
applyDelta delta ( game, outcomes ) =
    case delta of
        DeltaNone ->
            ( game, outcomes )

        DeltaList list ->
            List.foldl applyDelta ( game, outcomes ) list

        DeltaGame f ->
            ( f game, outcomes )

        DeltaOutcome o ->
            ( game, o :: outcomes )

        DeltaLater delay later ->
            let
                laters =
                    ( game.time + delay, later ) :: game.laters
            in
            ( { game | laters = laters }, outcomes )

        DeltaRandom deltaGenerator ->
            let
                ( d, seed ) =
                    Random.step deltaGenerator game.seed
            in
            applyDelta d ( { game | seed = seed }, outcomes )

        DeltaNeedsUpdatedGame gameToDelta ->
            applyDelta (gameToDelta game) ( game, outcomes )


applyGameDeltas : Game -> List Delta -> ( Game, List Outcome )
applyGameDeltas game deltas =
    List.foldl applyDelta ( game, [] ) deltas
