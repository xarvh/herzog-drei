module SetupPhase exposing (..)

import ColorPattern exposing (ColorPattern)
import Dict exposing (Dict)
import Game exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Mech
import Random
import Set exposing (Set)
import Svgl.Tree exposing (..)
import Unit
import View.Hud


neutralTilesHalfWidth =
    8



-- Think


think : List String -> Game -> Delta
think inputSources game =
    deltaList
        [ addAndRemoveMechs inputSources game
        , if game.maybeTransition /= Nothing then
            deltaNone
          else
            deltaList
                [ updateAllMechsTeam game
                , maybeExitSetupPhase game
                ]
        ]



-- Add & Remove Mechs


addMech : String -> Delta
addMech inputSourceKey =
    let
        startingPosition =
            vec2 0 0

        update game =
            game
                |> generateRandom Mech.classGenerator
                |> (\( class, g ) -> Game.addMech class inputSourceKey Nothing startingPosition g)
                |> Tuple.first
    in
    deltaGame update


removeMech : String -> Delta
removeMech inputSourceKey =
    let
        keepUnit id unit =
            case Unit.toMech unit of
                Nothing ->
                    True

                Just ( u, mech ) ->
                    mech.inputKey /= inputSourceKey
    in
    deltaGame <|
        \g ->
            { g | unitById = Dict.filter keepUnit g.unitById }


addAndRemoveMechs : List String -> Game -> Delta
addAndRemoveMechs inputSources game =
    let
        inputs =
            inputSources |> Set.fromList

        mechs =
            game.unitById
                |> Dict.values
                |> List.filterMap Unit.toMech
                |> List.map (Tuple.second >> .inputKey)
                |> Set.fromList

        -- ensure that there is a player for any input
        inputsWithoutMech =
            Set.diff inputs mechs |> Set.toList

        -- remove players without input
        mechsWithoutInput =
            Set.diff mechs inputs |> Set.toList
    in
    [ List.map addMech inputsWithoutMech
    , List.map removeMech mechsWithoutInput
    ]
        |> List.map deltaList
        |> deltaList



-- Mech Team


updateMechTeam : Game -> ( Unit, MechComponent ) -> Delta
updateMechTeam game ( unit, mech ) =
    let
        setTeam maybeTeamId =
            if unit.maybeTeamId == maybeTeamId then
                deltaNone
            else
                deltaList
                    [ deltaUnit unit.id (\g u -> { u | maybeTeamId = maybeTeamId })
                    ]
    in
    if Vec2.getX unit.position < -neutralTilesHalfWidth then
        setTeam (Just game.leftTeam.id)
    else if Vec2.getX unit.position > neutralTilesHalfWidth then
        setTeam (Just game.rightTeam.id)
    else
        setTeam Nothing


updateAllMechsTeam : Game -> Delta
updateAllMechsTeam game =
    game.unitById
        |> Dict.values
        |> List.filterMap Unit.toMech
        |> List.map (updateMechTeam game)
        |> deltaList


isReady : ( Unit, MechComponent ) -> Bool
isReady ( unit, mech ) =
    unit.maybeTeamId /= Nothing


teamSeed : Team -> Game -> TeamSeed
teamSeed team game =
    { colorPattern = team.colorPattern
    , mechClassByInputKey =
        game.unitById
            |> Dict.values
            |> List.filter (\u -> u.maybeTeamId == Just team.id)
            |> List.filterMap Unit.toMech
            |> List.map (\( unit, mech ) -> ( mech.inputKey, mech.class ))
            |> Dict.fromList
    }


maybeExitSetupPhase : Game -> Delta
maybeExitSetupPhase game =
    let
        mechs =
            game.unitById
                |> Dict.values
                |> List.filterMap Unit.toMech
    in
    if mechs /= [] && List.all isReady mechs then
        deltaList
            [ deltaGame startTransition
            , DeltaOutcome OutcomeCanAddBots
            ]
    else
        deltaNone


startTransition : Game -> Game
startTransition game =
    let
        mechs =
            game.unitById
                |> Dict.values
                |> List.filterMap Unit.toMech

        mechClassByInputKey teamId =
            mechs
                |> List.filter (\( u, m ) -> u.maybeTeamId == Just teamId)
                |> List.map Tuple.second
                |> List.map (\mech -> ( mech.inputKey, mech.class ))
                |> Dict.fromList

        addPlayers team =
            { team | mechClassByInputKey = mechClassByInputKey team.id }
    in
    { game | maybeTransition = Just { start = game.time, fade = GameFadeOut } }
        |> updateTeam (addPlayers game.leftTeam)
        |> updateTeam (addPlayers game.rightTeam)



-- View


viewArrows : Angle -> ColorPattern -> Float -> Game -> Node
viewArrows direction colorPattern x game =
    let
        hh =
            game.halfHeight - 1

        params =
            { fill = colorPattern.darkV
            , stroke = colorPattern.brightV
            }

        arrow y =
            Nod
                [ translate2 (x + 0.1 * periodHarmonic game.time (0.17 * toFloat y) 1) (toFloat y)
                , rotateRad direction
                ]
                [ View.Hud.arrow colorPattern.darkV colorPattern.brightV ]
    in
    List.range -hh hh
        |> List.map arrow
        |> Nod []


view : Game -> List Node
view game =
    [ viewArrows (degrees -90) game.leftTeam.colorPattern -neutralTilesHalfWidth game
    , viewArrows (degrees 90) game.rightTeam.colorPattern neutralTilesHalfWidth game
    ]
