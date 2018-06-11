module SetupPhase exposing (..)

import ColorPattern exposing (ColorPattern)
import Dict exposing (Dict)
import Game exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Mech
import Random
import Set exposing (Set)
import Svg exposing (..)
import Svg.Attributes as SA
import Unit
import View exposing (..)
import View.Background


neutralTilesHalfWidth =
    8



-- Think


think : List String -> Game -> Delta
think inputSources game =
    deltaList
        [ addAndRemoveMechs inputSources game
        , updateAllMechsTeam game
        , if game.maybeTransitionStart == Nothing then
            maybeExitSetupPhase game
          else
            deltaNone
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
    if game.maybeTransitionStart /= Nothing then
        deltaNone
    else
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
    { game | maybeTransitionStart = Just game.time }
        |> updateTeam (addPlayers game.leftTeam)
        |> updateTeam (addPlayers game.rightTeam)



-- View


drawRect : String -> String -> View.Background.Rect -> Svg a
drawRect fillColor strokeColor rect =
    Svg.rect
        [ x rect.x
        , y rect.y
        , width rect.w
        , height rect.h
        , fill fillColor
        , strokeWidth 0.04
        , stroke strokeColor
        ]
        []


viewTeamRects : ColorPattern -> List View.Background.Rect -> Svg a
viewTeamRects pattern rects =
    let
        gradientId =
            pattern.key ++ "AnimatedGradient"

        rectFillColor =
            "url(#" ++ gradientId ++ ")"
    in
    g
        []
        [ defs
            []
            [ linearGradient
                [ SA.id gradientId
                , SA.spreadMethod "reflect"
                , SA.x1 "0%"
                , SA.y1 "0%"
                , SA.x2 "100%"
                , SA.y2 "0%"
                ]
                [ stop
                    [ SA.offset "0"
                    , SA.style <| "stop-color:" ++ pattern.bright
                    ]
                    [ animate
                        [ SA.id "left1"
                        , SA.attributeName "stop-color"
                        , [ pattern.dark, pattern.bright, pattern.dark ]
                            |> String.join ";"
                            |> SA.values
                        , SA.from "1"
                        , SA.to "0"
                        , SA.dur "5s"
                        , SA.repeatCount "indefinite"
                        ]
                        []
                    ]
                , stop
                    [ SA.offset "1"
                    , SA.style <| "stop-color:" ++ pattern.dark
                    ]
                    [ animate
                        [ SA.id "left1"
                        , SA.attributeName "stop-color"
                        , [ pattern.bright, pattern.dark, pattern.bright ]
                            |> String.join ";"
                            |> SA.values
                        , SA.from "1"
                        , SA.to "0"
                        , SA.dur "5s"
                        , SA.repeatCount "indefinite"
                        ]
                        []
                    ]
                ]
            ]
        , rects
            |> List.map (drawRect rectFillColor pattern.dark)
            |> g []
        ]


view : List View.Background.Rect -> Game -> Svg a
view rects game =
    let
        leftRects =
            rects
                |> List.filter (\rect -> rect.x + rect.w / 2 < -neutralTilesHalfWidth)
                |> List.sortBy (\r -> -r.x)
    in
    g
        []
        [ rects
            |> List.filter (\rect -> rect.x + rect.w / 2 < -neutralTilesHalfWidth)
            |> List.sortBy (\r -> -r.x)
            |> viewTeamRects game.leftTeam.colorPattern
        , rects
            |> List.filter (\rect -> rect.x + rect.w / 2 > neutralTilesHalfWidth)
            |> List.sortBy .x
            |> viewTeamRects game.rightTeam.colorPattern
        , text_
            [ transform [ scale2 1 -1 ]
            , y (2 - toFloat game.halfHeight)
            , SA.textAnchor "middle"
            , SA.fontSize "1"
            , SA.fontFamily "'NewAcademy', sans-serif"
            , SA.fontWeight "700"
            , textNotSelectable
            ]
            [ text "Move to a color" ]
        , text_
            [ transform [ scale2 1 -1 ]
            , y (-2 + toFloat game.halfHeight)
            , SA.textAnchor "middle"
            , SA.fontSize "0.7"
            , SA.fontFamily "'NewAcademy', sans-serif"
            , SA.fontWeight "700"
            , textNotSelectable
            ]
            [ text "Press Q or Rally to change mech" ]
        ]
