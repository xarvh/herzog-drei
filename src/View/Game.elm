module View.Game exposing (..)

import Base
import ColorPattern exposing (ColorPattern, neutral)
import Colors
import Dict exposing (Dict)
import Game exposing (..)
import Html exposing (Html)
import List.Extra
import Map exposing (Map)
import Math.Matrix4 as Mat4 exposing (Mat4)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Mech
import Set exposing (Set)
import SetupPhase
import SplitScreen exposing (Viewport)
import Stats
import Svgl.Primitives
import Svgl.Tree exposing (..)
import Unit
import Update
import View.Base
import View.Gfx
import View.Hud
import View.Mech
import View.Projectile
import View.Sub
import WebGL exposing (Entity, Mesh, Shader)


view : Viewport -> Game -> Html a
view viewport game =
    let
        units =
            game.unitById
                |> Dict.values
                |> List.sortBy .id

        ( mechs, subs ) =
            mechVsUnit units

        ( freeSubs, baseSubs ) =
            List.partition (\( unit, sub ) -> sub.mode == UnitModeFree) subs

        ( flyingMechs, walkingMechs ) =
            List.partition (\( unit, mech ) -> Mech.transformMode mech == ToFlyer) mechs

        shake =
            Vec2.toRecord game.shakeVector

        worldToCamera =
            worldToCameraMatrix game viewport
                |> Mat4.translate (vec3 shake.x shake.y 0)
    in
    [ viewSetup game
    , freeSubs |> List.map (viewSub game)
    , walkingMechs |> List.map (viewMech game)
    , game.wallTiles |> Set.toList |> List.map viewWall
    , game.baseById |> Dict.values |> List.map (viewBase game)
    , baseSubs |> List.map (viewSub game)
    , flyingMechs |> List.map (viewMech game)
    , game.projectileById |> Dict.values |> List.map (viewProjectile game)
    , if game.mode /= GameModeVersus then
        []
      else
        [ game.leftTeam, game.rightTeam ] |> List.map (viewRallyPoint game)
    , game.cosmetics |> List.map (View.Gfx.view game)
    , units |> List.map viewHealthbar
    , units |> List.map (viewCharge game)
    ]
        |> List.concat
        |> Nod []
        |> treeToEntities worldToCamera
        |> List.map Tuple.second
        |> WebGL.toHtmlWith
            [ WebGL.alpha True
            , WebGL.antialias
            ]
            (SplitScreen.viewportToWebGLAttributes viewport)



-- Viewport


tilesToViewport : { a | halfWidth : Int, halfHeight : Int } -> Viewport -> Float
tilesToViewport { halfWidth, halfHeight } viewport =
    SplitScreen.fitWidthAndHeight (toFloat halfWidth * 2) (toFloat halfHeight * 2) viewport


worldToCameraMatrix : { a | halfWidth : Int, halfHeight : Int } -> Viewport -> Mat4
worldToCameraMatrix size viewport =
    let
        normalizedSize =
            SplitScreen.normalizedSize viewport

        viewportScale =
            2 / tilesToViewport size viewport
    in
    Mat4.makeScale (vec3 (viewportScale / normalizedSize.width) (viewportScale / normalizedSize.height) 1)



-- Helpers


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



-- Views


viewSetup : Game -> List Node
viewSetup game =
    case game.mode of
        GameModeTeamSelection _ ->
            SetupPhase.view game

        _ ->
            []


viewSub : Game -> ( Unit, SubComponent ) -> Node
viewSub game ( unit, subRecord ) =
    let
        colorPattern =
            Game.teamColorPattern game unit.maybeTeamId

        z =
            case subRecord.mode of
                UnitModeFree ->
                    0

                UnitModeBase _ ->
                    Stats.maxHeight.base
    in
    Nod
        [ translateVz unit.position z ]
        [ View.Sub.sub
            { lookAngle = unit.lookAngle
            , moveAngle = unit.moveAngle
            , fireAngle = unit.fireAngle
            , bright = colorPattern.brightV
            , dark = colorPattern.darkV
            , isBig = subRecord.isBig
            }

        --, View.Sub.collider unit.moveAngle (vec2 0 0) |> View.renderCollider
        ]


viewMech : Game -> ( Unit, MechComponent ) -> Node
viewMech game ( unit, mech ) =
    let
        colorPattern =
            Game.teamColorPattern game unit.maybeTeamId
    in
    Nod
        [ translate unit.position ]
        [ View.Mech.mech mech.class
            { transformState = mech.transformState
            , lookAngle = unit.lookAngle
            , fireAngle = unit.fireAngle
            , fill = colorPattern.brightV
            , stroke = colorPattern.darkV
            , time = game.time
            }

        --, View.Mech.collider mechRecord.transformState unit.fireAngle (vec2 0 0) |> View.renderCollider
        ]


viewBase : Game -> Base -> Node
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
    Nod
        [ translateVz base.position 0 ]
        [ case base.type_ of
            Game.BaseSmall ->
                View.Base.small completion colorPattern.brightV colorPattern.darkV

            Game.BaseMain ->
                View.Base.main_ completion colorPattern.brightV colorPattern.darkV
        , case buildTarget of
            Nothing ->
                Nod [] []

            Just mech ->
                View.Mech.mech mech.class
                    { transformState = 1
                    , lookAngle = 0
                    , fireAngle = 0
                    , fill = mix3 colorPattern.brightV colorPattern.darkV completion
                    , stroke = mix3 colorPattern.darkV colorPattern.brightV completion
                    , time = 0
                    }
        ]


viewProjectile : Game -> Projectile -> Node
viewProjectile game projectile =
    View.Projectile.projectile projectile.classId projectile.position projectile.angle (game.time - projectile.spawnTime)


viewWall : Tile2 -> Node
viewWall ( xi, yi ) =
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
            (1 + d) / 4
    in
    rect
        { defaultParams
            | fill = vec3 color color color
            , stroke = vec3 color color color
            , x = xf + 0.5
            , y = yf + 0.5
            , rotate = degrees rot
            , w = 1.1
            , h = 1.1
        }


viewRallyPoint : Game -> Team -> Node
viewRallyPoint game team =
    Nod
        [ translate team.markerPosition ]
        [ View.Hud.rallyPoint game.time team.colorPattern.darkV team.colorPattern.brightV ]


viewHealthbar : Unit -> Node
viewHealthbar unit =
    if unit.integrity > 0.95 then
        Nod [] []
    else
        Nod
            [ translate unit.position ]
            [ View.Hud.healthBar unit.integrity ]


viewCharge : Game -> Unit -> Node
viewCharge game unit =
    case unit.maybeCharge of
        Just (Charging startTime) ->
            if game.time - startTime < 0.3 then
                Nod [] []
            else
                Nod
                    [ translate unit.position ]
                    [ View.Hud.chargeBar ((game.time - startTime) / Stats.heli.chargeTime) ]

        Just (Stretching startTime) ->
            Mech.heliSalvoPositions (game.time - startTime) unit
                |> List.map (View.Hud.salvoMark game.time (Unit.colorPattern game unit))
                |> Nod []

        _ ->
            Nod [] []



{-
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
-}
-- Map editor


viewMap : Viewport -> Map -> Html a
viewMap viewport map =
    let
        worldToCamera =
            worldToCameraMatrix map viewport
    in
    [ map.wallTiles |> Set.toList |> List.map viewWall
    , map.bases |> Dict.toList |> List.map viewMapEditorBase
    ]
        |> List.concat
        |> Nod []
        |> treeToEntities worldToCamera
        |> List.map Tuple.second
        |> WebGL.toHtmlWith
            [ WebGL.alpha True
            , WebGL.antialias
            ]
            (SplitScreen.viewportToWebGLAttributes viewport)


viewMapEditorBase : ( Tile2, BaseType ) -> Node
viewMapEditorBase ( tile, baseType ) =
    let
        colorPattern =
            ColorPattern.neutral
    in
    Nod
        [ translate (tile2Vec tile) ]
        [ case baseType of
            Game.BaseSmall ->
                View.Base.small 0 colorPattern.brightV colorPattern.darkV

            Game.BaseMain ->
                View.Base.main_ 0 colorPattern.brightV colorPattern.darkV
        ]
