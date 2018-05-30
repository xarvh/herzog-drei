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


getTeams : Game -> ( Team, Team )
getTeams game =
    case game.teamById |> Dict.values |> List.sortBy .id of
        leftTeam :: rightTeam :: _ ->
            ( leftTeam, rightTeam )

        _ ->
            Debug.crash "WTF"



-- update


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


updatePlayerTeam : Game -> Player -> Delta
updatePlayerTeam game player =
    case Unit.findMech player.inputSourceKey (Dict.values game.unitById) of
        Nothing ->
            deltaNone

        Just ( unit, mech ) ->
            let
                ( leftTeam, rightTeam ) =
                    getTeams game

                setTeam teamId =
                    if player.teamId == teamId then
                        deltaNone
                    else
                        deltaList
                            [ deltaPlayer player.inputSourceKey (\g p -> { p | teamId = teamId })
                            , deltaUnit unit.id (\g u -> { u | teamId = teamId })
                            ]
            in
            if Vec2.getX unit.position < -neutralTilesHalfWidth then
                setTeam leftTeam.id
            else if Vec2.getX unit.position > neutralTilesHalfWidth then
                setTeam rightTeam.id
            else
                setTeam -1


updatePlayersTeam : Game -> Delta
updatePlayersTeam game =
    game.playerByKey
        |> Dict.values
        |> List.map (updatePlayerTeam game)
        |> deltaList



-- View


viewBands : Game -> Svg a
viewBands game =
    let
        ( leftTeam, rightTeam ) =
            getTeams game

        w =
            3

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
