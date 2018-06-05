module View.Game exposing (..)

import Base
import ColorPattern exposing (neutral)
import Dict exposing (Dict)
import Game exposing (..)
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Phases
import Set exposing (Set)
import SplitScreen exposing (Viewport)
import String.Extra
import Svg exposing (..)
import Svg.Attributes
import Svg.Lazy
import View exposing (..)
import View.Background
import View.Base
import View.Gfx
import View.Hud
import View.Mech
import View.Projectile
import View.Sub


checkersBackground : Game -> Svg a
checkersBackground game =
    let
        squareSize =
            1.0

        s =
            squareSize

        s2 =
            squareSize * 2
    in
    Svg.g
        []
        [ Svg.defs
            []
            [ Svg.pattern
                [ Svg.Attributes.id "grid"
                , width s2
                , height s2
                , Svg.Attributes.patternUnits "userSpaceOnUse"
                ]
                [ Svg.rect
                    [ x 0
                    , y 0
                    , width s
                    , height s
                    , fill "#eee"
                    ]
                    []
                , Svg.rect
                    [ x s
                    , y s
                    , width s
                    , height s
                    , fill "#eee"
                    ]
                    []
                ]
            ]
        , Svg.rect
            [ fill "url(#grid)"
            , x (toFloat -game.halfWidth)
            , y (toFloat -game.halfHeight)
            , width (toFloat <| game.halfWidth * 2)
            , height (toFloat <| game.halfHeight * 2)
            ]
            []
        ]


circle : Vec2 -> String -> Float -> Svg a
circle pos color size =
    Svg.circle
        [ cx <| Vec2.getX pos
        , cy <| Vec2.getY pos
        , r size
        , fill color
        ]
        []


viewBase : Game -> Base -> Svg a
viewBase game base =
    let
        colorPattern =
            Base.colorPattern game base

        ( buildTarget, completion ) =
            case base.maybeOccupied of
                Nothing ->
                    ( "sub", 0 )

                Just occupied ->
                    occupied.mechBuildCompletions
                        |> List.Extra.maximumBy Tuple.second
                        |> Maybe.withDefault ( "sub", occupied.subBuildCompletion )
    in
    Svg.g
        [ transform [ translate base.position ] ]
        [ case base.type_ of
            Game.BaseSmall ->
                View.Base.small completion colorPattern.bright colorPattern.dark

            Game.BaseMain ->
                View.Base.main_ completion colorPattern.bright colorPattern.dark
        , if buildTarget == "sub" then
            Svg.text ""
          else
            Svg.g
                [ 0.9
                    * completion
                    + 0.1
                    * sin (pi * completion * 10)
                    |> opacity
                ]
                [ View.Mech.mech 1 0 0 neutral.dark colorPattern.dark ]
        ]


viewMech : Game -> ( Unit, MechComponent ) -> Svg a
viewMech game ( unit, mechRecord ) =
    let
        colorPattern =
            Game.teamColorPattern game unit.maybeTeamId
    in
    Svg.g
        [ transform [ translate unit.position ] ]
        [ View.Mech.mech
            mechRecord.transformState
            unit.lookAngle
            unit.fireAngle
            colorPattern.bright
            colorPattern.dark

        --, View.Mech.collider mechRecord.transformState unit.fireAngle (vec2 0 0) |> View.renderCollider
        ]


viewSub : Game -> ( Unit, SubComponent ) -> Svg a
viewSub game ( unit, subRecord ) =
    let
        colorPattern =
            Game.teamColorPattern game unit.maybeTeamId
    in
    Svg.g
        [ transform [ translate unit.position ] ]
        [ View.Sub.sub
            unit.lookAngle
            unit.moveAngle
            unit.fireAngle
            colorPattern.bright
            colorPattern.dark

        --, View.Sub.collider unit.moveAngle (vec2 0 0) |> View.renderCollider
        ]


mechVsUnit : List Unit -> ( List ( Unit, MechComponent ), List ( Unit, SubComponent ) )
mechVsUnit units =
    let
        folder unit ( mechs, subs ) =
            case unit.component of
                UnitMech mechRecord ->
                    ( ( unit, mechRecord ) :: mechs, subs )

                UnitSub subRecord ->
                    ( mechs, ( unit, subRecord ) :: subs )
    in
    List.foldl folder ( [], [] ) units


viewMarker : Game -> Team -> Svg a
viewMarker game team =
    circle team.markerPosition team.colorPattern.dark 0.2


viewProjectile : Projectile -> Svg a
viewProjectile projectile =
    View.Projectile.projectile projectile.position projectile.angle


viewHealthbar : Unit -> Svg a
viewHealthbar unit =
    if unit.integrity > 0.95 then
        Svg.text ""
    else
        View.Hud.healthBar unit.position unit.integrity


wall : Tile2 -> Svg a
wall ( xi, yi ) =
    let
        xf =
            toFloat xi

        yf =
            toFloat yi

        c =
            sin (xf * 9982399) + sin (yf * 17324650)

        d =
            sin (xf * 1372347) + sin (yf * 98325987)

        rot =
            5 * c

        color =
            (1 + d) / 4 * 255 |> floor |> toString
    in
    Svg.rect
        [ transform [ translate2 (xf + 0.5) (yf + 0.5), rotateDeg rot ]
        , x -0.55
        , y -0.55
        , width 1.1
        , height 1.1
        , fill <| "rgb(" ++ color ++ "," ++ color ++ "," ++ color ++ ")"
        ]
        []



-- Victory


viewVictory : Game -> Svg a
viewVictory game =
    case maybeGetTeam game game.maybeWinnerTeamId of
        Nothing ->
            text ""

        Just team ->
            let
                pattern =
                    team.colorPattern
            in
            text_
                [ Svg.Attributes.textAnchor "middle"
                , Svg.Attributes.fontSize "0.2"
                , Svg.Attributes.fontFamily "'NewAcademy', sans-serif"
                , Svg.Attributes.fontWeight "700"
                , Svg.Attributes.fill pattern.bright
                , Svg.Attributes.stroke pattern.dark
                , Svg.Attributes.strokeWidth "0.005"
                , Svg.Attributes.y "-0.2"
                , Svg.Attributes.style "user-select: none;"
                ]
                [ String.Extra.toTitleCase pattern.key ++ " wins!" |> text ]



-- Main


tilesToViewport : Game -> Viewport -> Float
tilesToViewport game viewport =
    SplitScreen.fitWidthAndHeight (toFloat game.halfWidth * 2) (toFloat game.halfHeight * 2) viewport


view : List View.Background.Rect -> Viewport -> Game -> Svg a
view terrain viewport game =
    let
        units =
            game.unitById |> Dict.values

        ( mechs, subs ) =
            mechVsUnit units

        maybeOpacity =
            case game.maybeTransition of
                Nothing ->
                    []

                Just transition ->
                    [ opacity transition ]
    in
    Svg.svg
        (SplitScreen.viewportToSvgAttributes viewport)
        [ Svg.g
            [ transform [ "scale(1 -1)", scale (1 / tilesToViewport game viewport) ]
            ]
            [ Svg.Lazy.lazy View.Background.terrain terrain
            , Svg.g maybeOpacity
                [ if game.phase == PhaseSetup then
                    Phases.viewSetup terrain game
                  else
                    Svg.text ""
                , subs
                    |> List.filter (\( u, s ) -> s.mode == UnitModeFree)
                    |> List.map (viewSub game)
                    |> Svg.g []
                , game.wallTiles
                    |> Set.toList
                    |> List.map wall
                    |> Svg.g []
                , game.baseById
                    |> Dict.values
                    |> List.map (viewBase game)
                    |> Svg.g []
                , subs
                    |> List.filter (\( u, s ) -> s.mode /= UnitModeFree)
                    |> List.map (viewSub game)
                    |> Svg.g []
                , mechs
                    |> List.map (viewMech game)
                    |> Svg.g []
                , [ game.leftTeam, game.rightTeam ]
                    |> List.map (viewMarker game)
                    |> Svg.g []
                , game.projectileById
                    |> Dict.values
                    |> List.map viewProjectile
                    |> Svg.g []
                , game.cosmetics
                    |> List.map View.Gfx.render
                    |> Svg.g []
                , units
                    |> List.map viewHealthbar
                    |> Svg.g []
                ]
            ]
        , viewVictory game
        ]
