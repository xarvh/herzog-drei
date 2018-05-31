module SetupPhase exposing (..)

import Dict exposing (Dict)
import Game exposing (..)
import Game.Init
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Set exposing (Set)
import Svg exposing (..)
import Unit
import View exposing (..)


-- Bands


neutralTilesHalfWidth =
    5


teamTilesWidth =
    3



-- phase update


phaseTransitionDuration =
    2.0


phaseUpdate : Seconds -> GamePhase
phaseUpdate time =
    if time >= phaseTransitionDuration then
        PhasePlay
    else
        PhaseTransition time


phasesWeight : GamePhase -> ( Float, Float )
phasesWeight phase =
    case phase of
        PhaseSetup ->
            ( 1, 0 )

        PhaseTransition seconds ->
            let
                t =
                    2 * seconds / phaseTransitionDuration

                setup =
                    clamp 0 1 (1 - t)

                play =
                    clamp 0 1 (t - 1)
            in
            ( setup, play )

        PhasePlay ->
            ( 0, 1 )



-- Think


think : List String -> Game -> Delta
think inputSources game =
    deltaList
        [ addAndRemoveMechs inputSources game
        , updateAllMechsTeam game
        , maybeExitSetupPhase game
        ]



-- Add & Remove Mechs


addMech : String -> Delta
addMech inputSourceKey =
    deltaGame <|
        \g ->
            let
                startingPosition =
                    vec2 0 0
            in
            g
                |> Game.addMech inputSourceKey Nothing startingPosition
                |> Tuple.first


removeMech : String -> Delta
removeMech inputSourceKey =
    deltaNone


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



-- Exit Setup Phase ?


makeTeams : Game -> ( Team, Team )
makeTeams game =
    -- TODO
    ( game.leftTeam, game.rightTeam )


addMechForEveryPlayer : Game -> Game
addMechForEveryPlayer game =
    -- TODO
    game


exitSetupPhase : Game -> Game
exitSetupPhase game =
    let
        ( left, right ) =
            makeTeams game

        walls =
            Game.Init.walls
    in
    { game
        | unitById = Dict.empty
        , wallTiles = Set.fromList walls
        , phase = PhaseTransition 0
    }
        |> Game.addStaticObstacles walls
        |> Game.Init.addSmallBase ( -5, 2 )
        |> Game.Init.addSmallBase ( 5, -2 )
        |> Game.Init.addMainBase (Just left.id) ( -16, -6 )
        |> Game.Init.addMainBase (Just right.id) ( 16, 6 )
        |> Game.Init.kickstartPathing
        |> addMechForEveryPlayer


isReady : ( Unit, MechComponent ) -> Bool
isReady ( unit, mech ) =
    abs (Vec2.getX unit.position) > neutralTilesHalfWidth + teamTilesWidth


maybeExitSetupPhase : Game -> Delta
maybeExitSetupPhase game =
    let
        mechs =
            game.unitById
                |> Dict.values
                |> List.filterMap Unit.toMech
    in
    if mechs /= [] && List.all isReady mechs then
        deltaGame exitSetupPhase
    else
        deltaNone



-- View


view : Game -> Svg a
view game =
    let
        w =
            teamTilesWidth

        h =
            2 + 2 * game.halfHeight |> toFloat
    in
    g
        []
        [ rect
            [ x (-neutralTilesHalfWidth - w)
            , y (-h / 2)
            , width w
            , height h
            , fill game.leftTeam.colorPattern.bright
            , stroke game.leftTeam.colorPattern.dark
            , strokeWidth 0.1
            ]
            []
        , rect
            [ x neutralTilesHalfWidth
            , y (-h / 2)
            , width w
            , height h
            , fill game.rightTeam.colorPattern.bright
            , stroke game.rightTeam.colorPattern.dark
            , strokeWidth 0.1
            ]
            []
        ]
