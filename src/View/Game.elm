module View.Game exposing (..)

import Base
import ColorPattern exposing (ColorPattern, neutral)
import Dict exposing (Dict)
import Game exposing (..)
import List.Extra
import Map exposing (Map)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Set exposing (Set)
import SetupPhase
import SplitScreen exposing (Viewport)
import Svg exposing (..)
import Svg.Attributes
import Svg.Lazy
import Update
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
                    ( Nothing, 0 )

                Just occupied ->
                    occupied.mechBuildCompletions
                        |> List.Extra.maximumBy Tuple.second
                        |> Maybe.map (Tuple.mapFirst Just)
                        |> Maybe.withDefault ( Nothing, occupied.subBuildCompletion )
    in
    Svg.g
        [ transform [ translate base.position ] ]
        [ case base.type_ of
            Game.BaseSmall ->
                View.Base.small completion colorPattern.bright colorPattern.dark

            Game.BaseMain ->
                View.Base.main_ completion colorPattern.bright colorPattern.dark
        , case buildTarget of
            Nothing ->
                text ""

            Just mech ->
                g
                    [ 0.9
                        * completion
                        + 0.1
                        * sin (pi * completion * 10)
                        |> opacity
                    ]
                    [ View.Mech.mech mech.class
                        { transformState = 1
                        , lookAngle = 0
                        , fireAngle = 0
                        , fill = neutral.dark
                        , stroke = colorPattern.dark
                        , time = game.time
                        }
                    ]
        ]


viewMapEditorBase : ( Tile2, BaseType ) -> Svg a
viewMapEditorBase ( tile, baseType ) =
    let
        colorPattern =
            ColorPattern.neutral
    in
    Svg.g
        [ transform [ translate (tile2Vec tile) ] ]
        [ case baseType of
            Game.BaseSmall ->
                View.Base.small 0 colorPattern.bright colorPattern.dark

            Game.BaseMain ->
                View.Base.main_ 0 colorPattern.bright colorPattern.dark
        ]


viewMech : Game -> ( Unit, MechComponent ) -> Svg a
viewMech game ( unit, mech ) =
    let
        colorPattern =
            Game.teamColorPattern game unit.maybeTeamId
    in
    Svg.g
        [ transform [ translate unit.position ] ]
        [ View.Mech.mech mech.class
            { transformState = mech.transformState
            , lookAngle = unit.lookAngle
            , fireAngle = unit.fireAngle
            , fill = colorPattern.bright
            , stroke = colorPattern.dark
            , time = game.time
            }

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
            subRecord.isBig

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


arrowUp : String -> String -> Svg a
arrowUp fillColor strokeColor =
    path
        [ [ "M -1,0"
          , "L 0,1"
          , "L 1,0"
          , "L 0.5,0"
          , "L 0.5,-1"
          , "L -0.5,-1"
          , "L -0.5,0"
          , "Z"
          ]
            |> String.join " "
            |> d
        , fill fillColor
        , stroke strokeColor
        , strokeWidth 0.2
        ]
        []


viewMarker : Game -> Team -> Svg a
viewMarker game team =
    let
        fillColor =
            team.colorPattern.dark

        strokeColor =
            team.colorPattern.bright

        distance =
            2 + 1 * periodHarmonic game 0 1.2

        an =
            periodHarmonic game 0.1 20 * 180

        arrow angle =
            g
                [ transform
                    [ rotateDeg angle
                    , scale 0.4
                    , translate2 0 -distance
                    ]
                ]
                [ arrowUp fillColor strokeColor ]
    in
    g
        [ transform [ translate team.markerPosition, scale -0.5 ]
        ]
        [ ellipse
            [ fill fillColor
            , stroke strokeColor
            , strokeWidth 0.1
            , rx 0.5
            , ry 0.6
            ]
            []
        , ellipse
            [ fill fillColor
            , stroke strokeColor
            , strokeWidth 0.07
            , cy 0.27
            , rx 0.25
            , ry 0.3
            ]
            []
        , arrow (an + 45)
        , arrow (an + 135)
        , arrow (an + 225)
        , arrow (an + -45)
        ]


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
            (1 + d) / 4 * 255 |> floor |> String.fromInt
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
                , textNotSelectable
                ]
                --TODO [ String.Extra.toTitleCase pattern.key ++ " wins!" |> text ]
                [ pattern.key ++ " wins!" |> text ]



-- Main


tilesToViewport : { a | halfWidth : Int, halfHeight : Int } -> Viewport -> Float
tilesToViewport { halfWidth, halfHeight } viewport =
    SplitScreen.fitWidthAndHeight (toFloat halfWidth * 2) (toFloat halfHeight * 2) viewport


maybeOpacity game =
    case game.maybeTransition of
        Nothing ->
            []

        Just { start, fade } ->
            let
                t =
                    (game.time - start) / Update.transitionDuration

                o =
                    case fade of
                        GameFadeIn ->
                            t

                        GameFadeOut ->
                            1 - t
            in
            [ opacity o ]


view : List View.Background.Rect -> Viewport -> Game -> Svg a
view terrain viewport game =
    let
        units =
            game.unitById |> Dict.values

        ( mechs, subs ) =
            mechVsUnit units
    in
    Svg.svg
        (SplitScreen.viewportToSvgAttributes viewport)
        [ Svg.g
            [ transform [ "scale(1 -1)", scale (1 / tilesToViewport game viewport) ]
            ]
            [ Svg.Lazy.lazy View.Background.terrain terrain
            , g (maybeOpacity game)
                [ case game.mode of
                    GameModeTeamSelection _ ->
                        SetupPhase.view terrain game

                    _ ->
                        text ""
                , subs
                    |> List.filter (\( u, s ) -> s.mode == UnitModeFree)
                    |> List.map (viewSub game)
                    |> g []
                , game.wallTiles
                    |> Set.toList
                    |> List.map wall
                    |> g []
                , game.baseById
                    |> Dict.values
                    |> List.map (viewBase game)
                    |> g []
                , subs
                    |> List.filter (\( u, s ) -> s.mode /= UnitModeFree)
                    |> List.map (viewSub game)
                    |> g []
                , mechs
                    |> List.map (viewMech game)
                    |> g []
                , if game.mode /= GameModeVersus then
                    text ""
                  else
                    [ game.leftTeam, game.rightTeam ]
                        |> List.map (viewMarker game)
                        |> g []
                , game.projectileById
                    |> Dict.values
                    |> List.map viewProjectile
                    |> g []
                , game.cosmetics
                    |> List.map View.Gfx.render
                    |> g []
                , units
                    |> List.map viewHealthbar
                    |> g []
                ]
            ]
        , viewVictory game
        ]



-- Map editor


viewMap : List View.Background.Rect -> Viewport -> Map -> Svg a
viewMap terrain viewport map =
    Svg.svg
        (SplitScreen.viewportToSvgAttributes viewport)
        [ Svg.g
            [ transform [ "scale(1 -1)", scale (1 / tilesToViewport map viewport) ]
            ]
            [ Svg.Lazy.lazy View.Background.terrain terrain
            , g []
                [ map.wallTiles
                    |> Set.toList
                    |> List.map wall
                    |> g []
                , map.bases
                    |> Dict.toList
                    |> List.map viewMapEditorBase
                    |> g []
                ]
            ]
        ]
