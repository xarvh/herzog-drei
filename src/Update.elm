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
import VictoryThink
import View.Gfx


-- Main update function


update : Seconds -> Dict String ( InputState, InputState ) -> Game -> ( Game, List Outcome )
update uncappedDt pairedInputStatesByKey oldGame =
    let
        -- Cap dt to 0.1 secs to avoid time integration problems
        dt =
            min 0.1 uncappedDt

        newTime =
            oldGame.time + dt

        ( latersToExecute, latersToStore ) =
            List.partition (\( scheduledTime, delta ) -> scheduledTime < newTime) oldGame.laters

        units =
            Dict.values oldGame.unitById

        tempGame =
            { oldGame
                | time = oldGame.time + dt
                , laters = latersToStore
                , dynamicObstacles =
                    units
                        |> List.map (.position >> vec2Tile)
                        |> Set.fromList
            }
                -- TODO: this should become a lot nicer once all GFX are using game time
                |> updateGfxs dt
    in
    [ latersToExecute
        |> List.map laterToDelta
    , units
        |> List.map (UnitThink.think dt pairedInputStatesByKey tempGame)

    --
    , [ case tempGame.mode of
            GameModeTeamSelection _ ->
                SetupPhase.think (Dict.keys pairedInputStatesByKey) tempGame

            GameModeVersus ->
                VictoryThink.think dt tempGame
      ]

    --
    , [ transitionThink tempGame
      , deltaGame (screenShake dt)
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



-- Laters


laterToDelta : ( Seconds, SerialisedDelta ) -> Delta
laterToDelta ( scheduledTime, serialisedDelta ) =
    case serialisedDelta of
        SpawnDownwardRocket args ->
            MechThink.spawnDownwardRocket args



-- Gfxs


updateGfxs : Seconds -> Game -> Game
updateGfxs dt game =
    { game | cosmetics = List.filterMap (View.Gfx.update dt) game.cosmetics }



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


applyGameDeltas : Game -> List Delta -> ( Game, List Outcome )
applyGameDeltas game deltas =
    List.foldl applyDelta ( game, [] ) deltas
