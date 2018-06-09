module Phases exposing (..)

import Base
import ColorPattern exposing (ColorPattern)
import Dict exposing (Dict)
import Game exposing (..)
import Init
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Random
import Set exposing (Set)
import Svg exposing (..)
import Svg.Attributes as SA
import Unit
import View exposing (..)
import View.Background


-- Bands


neutralTilesHalfWidth =
    8



-- phase update


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



--


boolToClass : Bool -> MechClass
boolToClass bool =
    if bool then
        Heli
    else
        Plane


mechClassGenerator : Random.Generator MechClass
mechClassGenerator =
    Random.map boolToClass Random.bool


{-| TODO move this to Game.elm?
-}
generateRandom : Random.Generator a -> Game -> ( a, Game )
generateRandom generator game =
    let
        ( value, seed ) =
            Random.step generator game.seed
    in
    ( value, { game | seed = seed } )



-- Think


setupThink : List String -> Game -> Delta
setupThink inputSources game =
    if game.maybeTransition /= Nothing then
        deltaNone
    else
        deltaList
            [ addAndRemoveMechs inputSources game
            , updateAllMechsTeam game
            , maybeExitSetupPhase game
            ]



-- Add & Remove Mechs


addSetupPhaseMech : String -> Delta
addSetupPhaseMech inputSourceKey =
    deltaGame <|
        \g ->
            let
                startingPosition =
                    vec2 0 0

                classGenerator =
                    Random.map boolToClass Random.bool

                ( class, seed ) =
                    Random.step classGenerator g.seed
            in
            { g | seed = seed }
                |> Game.addMech class inputSourceKey Nothing startingPosition
                |> Tuple.first


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
    [ List.map addSetupPhaseMech inputsWithoutMech
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
                                    generateRandom mechClassGenerator game

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
    in
    { game
        | unitById = Dict.empty
        , wallTiles = Set.fromList walls
        , phase = PhasePlay
        , maybeTransition = Just 0
    }
        |> Game.addStaticObstacles walls
        |> Init.addSmallBase ( -5, 2 )
        |> Init.addSmallBase ( 5, -2 )
        |> Init.addMainBase (Just game.leftTeam.id) ( -16, -6 )
        |> Init.addMainBase (Just game.rightTeam.id) ( 16, 6 )
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


isReady : ( Unit, MechComponent ) -> Bool
isReady ( unit, mech ) =
    unit.maybeTeamId /= Nothing


maybeExitSetupPhase : Game -> Delta
maybeExitSetupPhase game =
    let
        mechs =
            game.unitById
                |> Dict.values
                |> List.filterMap Unit.toMech
    in
    if mechs /= [] && List.all isReady mechs then
        deltaGame (exitSetupPhase mechs)
    else
        deltaNone



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


viewSetup : List View.Background.Rect -> Game -> Svg a
viewSetup rects game =
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
