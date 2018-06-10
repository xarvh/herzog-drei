module Phases exposing (..)

import Base
import Dict exposing (Dict)
import Game exposing (..)
import Init
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Mech
import Set exposing (Set)
import Unit


-- Phase update


transitionDuration =
    1.0


transitionUpdate : Seconds -> Game -> Game
transitionUpdate dt game =
    case game.maybeTransition of
        Nothing ->
            game

        Just transition ->
            let
                d =
                    dt / transitionDuration
            in
            case game.phase of
                PhaseSetup ->
                    if transition - d > 0 then
                        -- continue fading out setup phase
                        { game | maybeTransition = Just (transition - d) }
                    else
                        -- start fading in Play phase
                        setupToPlayPhase game

                PhasePlay ->
                    if transition + d < 1 then
                        -- continue fading in Play phase
                        { game | maybeTransition = Just (transition + d) }
                    else
                        -- transitions complete
                        { game | maybeTransition = Nothing }



-- Exit Setup Phase ?


addMechsForTeam : Dict String MechClass -> Team -> Game -> Game
addMechsForTeam mechClassByInputKey team game =
    case Base.teamMainBase game (Just team.id) of
        Nothing ->
            game

        Just base ->
            let
                addPlayPhaseMech : String -> Game -> Game
                addPlayPhaseMech inputKey g =
                    let
                        ( class, newGame ) =
                            case Dict.get inputKey mechClassByInputKey of
                                Nothing ->
                                    generateRandom Mech.classGenerator game

                                Just class ->
                                    ( class, game )
                    in
                    Game.addMech class inputKey (Just team.id) base.position newGame |> Tuple.first
            in
            List.foldl addPlayPhaseMech game team.players


addMechForEveryPlayer : Dict String MechClass -> Game -> Game
addMechForEveryPlayer classByKey game =
    game
        |> addMechsForTeam classByKey game.leftTeam
        |> addMechsForTeam classByKey game.rightTeam


initMarkerPosition : Team -> Game -> Game
initMarkerPosition team game =
    case Base.teamMainBase game (Just team.id) of
        Nothing ->
            game

        Just base ->
            let
                markerPosition =
                    base.position
                        |> Vec2.negate
                        |> Vec2.normalize
                        |> Vec2.scale 5
                        |> Vec2.add base.position
            in
            updateTeam { team | markerPosition = markerPosition } game


setupToPlayPhase : Game -> Game
setupToPlayPhase game =
    let
        walls =
            Init.walls

        mechClassByInputKey =
            game.unitById
                |> Dict.values
                |> List.filterMap Unit.toMech
                |> List.map (\( unit, mech ) -> ( mech.inputKey, mech.class ))
                |> Dict.fromList

        map =
            game.validatedMap
    in
    { game
        | unitById = Dict.empty
        , wallTiles = map.wallTiles
        , phase = PhasePlay
        , maybeTransition = Just 0
    }
        |> Game.addStaticObstacles (Set.toList map.wallTiles)
        |> (\g -> Set.foldl Init.addSmallBase g map.smallBases)
        |> Init.addMainBase (Just game.leftTeam.id) map.leftBase
        |> Init.addMainBase (Just game.rightTeam.id) map.rightBase
        |> initMarkerPosition game.leftTeam
        |> initMarkerPosition game.rightTeam
        |> Init.kickstartPathing
        |> addMechForEveryPlayer mechClassByInputKey


addBots : Int -> List String -> Team -> Team
addBots targetSize humanPlayers team =
    let
        botsToAdd =
            targetSize - List.length humanPlayers

        botPlayers =
            List.range 1 botsToAdd |> List.map (\n -> inputBot team.id n)
    in
    { team | players = humanPlayers ++ botPlayers }


exitSetupPhase : List ( Unit, MechComponent ) -> Game -> Game
exitSetupPhase mechs game =
    let
        teamInputKeys teamId =
            mechs
                |> List.filter (\( u, m ) -> u.maybeTeamId == Just teamId)
                |> List.map (Tuple.second >> .inputKey)

        leftTeamInputKeys =
            teamInputKeys TeamLeft

        rightTeamInputKeys =
            teamInputKeys TeamRight

        teamsSize =
            max (List.length leftTeamInputKeys) (List.length rightTeamInputKeys)
    in
    { game | maybeTransition = Just 1 }
        |> updateTeam (addBots teamsSize leftTeamInputKeys game.leftTeam)
        |> updateTeam (addBots teamsSize rightTeamInputKeys game.rightTeam)
