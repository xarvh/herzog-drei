module SetupPhase exposing (..)

import Dict exposing (Dict)
import Game exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Set exposing (Set)
import Svg exposing (..)
import View exposing (..)


-- Bands


neutralTilesHalfWidth =
    5



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



-- View


viewBands : Game -> Svg a
viewBands game =
    case game.teamById |> Dict.values |> List.sortBy .id of
        leftTeam :: rightTeam :: _ ->
            let
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

        _ ->
            Debug.crash "WTF"


view : Game -> Svg a
view game =
    viewBands game
