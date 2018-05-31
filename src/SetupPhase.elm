module SetupPhase exposing (..)

import Dict exposing (Dict)
import Game exposing (..)
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


getTeams : Game -> ( Team, Team )
getTeams game =
    case game.teamById |> Dict.values |> List.sortBy .id of
        leftTeam :: rightTeam :: _ ->
            ( leftTeam, rightTeam )

        _ ->
            Debug.crash "WTF"



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
                |> Game.addMech inputSourceKey -1 startingPosition
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
        ( leftTeam, rightTeam ) =
            getTeams game

        setTeam teamId =
            if unit.teamId == teamId then
                deltaNone
            else
                deltaList
                    [ deltaUnit unit.id (\g u -> { u | teamId = teamId })
                    ]
    in
    if Vec2.getX unit.position < -neutralTilesHalfWidth then
        setTeam leftTeam.id
    else if Vec2.getX unit.position > neutralTilesHalfWidth then
        setTeam rightTeam.id
    else
        setTeam -1


updateAllMechsTeam : Game -> Delta
updateAllMechsTeam game =
    game.unitById
        |> Dict.values
        |> List.filterMap Unit.toMech
        |> List.map (updateMechTeam game)
        |> deltaList



-- Exit Setup Phase ?


exitSetupPhase : Game -> Game
exitSetupPhase game =
    game


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


viewBands : Game -> Svg a
viewBands game =
    let
        ( leftTeam, rightTeam ) =
            getTeams game

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
            , fill leftTeam.colorPattern.bright
            , stroke leftTeam.colorPattern.dark
            , strokeWidth 0.1
            ]
            []
        , rect
            [ x neutralTilesHalfWidth
            , y (-h / 2)
            , width w
            , height h
            , fill rightTeam.colorPattern.bright
            , stroke rightTeam.colorPattern.dark
            , strokeWidth 0.1
            ]
            []
        ]


view : Game -> Svg a
view game =
    viewBands game
