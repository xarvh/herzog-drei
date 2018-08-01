module View.Game exposing (..)

import Base
import ColorPattern exposing (ColorPattern, neutral)
import Colors
import Dict exposing (Dict)
import Game exposing (..)
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
import Svg exposing (Svg)
import Svgl.Primitives
import Svgl.Tree exposing (..)
import Unit
import Update
import View.Base
import View.Mech
import View.Projectile
import View.Sub
import WebGL exposing (Entity, Mesh, Shader)


-- Main


tilesToViewport : { a | halfWidth : Int, halfHeight : Int } -> Viewport -> Float
tilesToViewport { halfWidth, halfHeight } viewport =
    SplitScreen.fitWidthAndHeight (toFloat halfWidth * 2) (toFloat halfHeight * 2) viewport


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


view : q -> Viewport -> Game -> Svg a
view terrain viewport game =
    let
        units =
            game.unitById
                |> Dict.values
                -- This sorting is necessary to keep rendering order
                -- consistent when later we sort by Z
                |> List.sortBy .id

        ( mechs, subs ) =
            mechVsUnit units

        ( freeSubs, baseSubs ) =
            List.partition (\( unit, sub ) -> sub.mode == UnitModeFree) subs

        ( flyingMechs, walkingMechs ) =
            List.partition (\( unit, mech ) -> Mech.transformMode mech == ToFlyer) mechs

        normalizedSize =
            SplitScreen.normalizedSize viewport

        viewportScale =
            2 / tilesToViewport game viewport

        shake =
            -- TODO: Vec2.toRecord game.shakeVector
            Vec2.toRecord (vec2 0 0)

        worldToCamera =
            Mat4.identity
                |> Mat4.scale (vec3 (viewportScale / normalizedSize.width) (viewportScale / normalizedSize.height) 1)
                |> Mat4.translate (vec3 shake.x shake.y 0)
    in
    [ freeSubs |> List.map (viewSub game)
    , walkingMechs |> List.map (viewMech game)
    , game.wallTiles |> Set.toList |> List.map viewWall
    , game.baseById |> Dict.values |> List.map (viewBase game)
    , baseSubs |> List.map (viewSub game)
    , flyingMechs |> List.map (viewMech game)
    , game.projectileById |> Dict.values |> List.map (viewProjectile game)
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

        z =
            mech.transformState * Stats.maxHeight.base
    in
    Nod
        [ translateVz unit.position z ]
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
                Nod [] []

        {- TODO
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
        -}
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



{-
   Nod
       []
       [ rect
           { fill = vec3 0 0 0
           , z = 0
           , stroke = vec3 0 0 0
           , x = 0
           , y = 0
           , rotate = 0
           , w = 4
           , h = 2
           }
       ,
       ]
-}
{-
   e1 =
       Svgl.Primitives.rect
           { dimensions = vec2 10 3
           , z = 0
           , fill = vec3 1 0 0
           , stroke = vec3 0.5 0 0
           , strokeWidth = 0.5
           , entityToCamera =
               Mat4.identity
                   |> Mat4.translate (vec3 1 0 0)
                   |> Mat4.rotate (turns 0.3) (vec3 0 0 1)
                   |> Mat4.mul worldToCamera
           }

   e2 =
       Svgl.Primitives.ellipse
           { dimensions = vec2 10 3
           , z = 0
           , fill = vec3 0 1 0
           , stroke = vec3 0 0.5 0
           , strokeWidth = 0.5
           , entityToCamera =
               Mat4.identity
                   |> Mat4.translate (vec3 -1 0 0)
                   |> Mat4.rotate (degrees 20) (vec3 0 0 1)
                   |> Mat4.mul worldToCamera
           }

   node1 =
       Nod
           [ rotateRad (degrees 20), translate2 10 0 ]
           [ rect
               { fill = Colors.gunFill
               , z = 0
               , stroke = Colors.gunStroke
               , x = 0
               , y = 0
               , rotate = game.time / 4
               , w = 6
               , h = 2
               }
           ]

-}
--
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
               2 + 1 * periodHarmonic game.time 0 1.2

           an =
               periodHarmonic game.time 0.1 20 * 180

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



   viewHealthbar : Unit -> Svg a
   viewHealthbar unit =
       if unit.integrity > 0.95 then
           Svg.text ""
       else
           View.Hud.healthBar unit.position unit.integrity


   viewCharge : Game -> Unit -> Svg a
   viewCharge game unit =
       case unit.maybeCharge of
           Just (Charging startTime) ->
               if game.time - startTime < 0.3 then
                   text ""
               else
                   View.Hud.chargeBar unit.position ((game.time - startTime) / Stats.heli.chargeTime)

           Just (Stretching _ startTime) ->
               Mech.heliSalvoPositions (game.time - startTime) unit
                   |> List.map (View.Hud.salvoMark game.time (Unit.colorPattern game unit))
                   |> g []

           _ ->
               Svg.text ""


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












-}
{-
   Svg.svg
       (SplitScreen.viewportToSvgAttributes viewport)
       [ Svg.g
           [ transform
             [ "scale(1 -1)", scale (1 / tilesToViewport game viewport)
             , translate game.shakeVector
             ]
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
                   |> List.map (viewProjectile game.time)
                   |> g []
               , game.cosmetics
                   |> List.map View.Gfx.render
                   |> g []
               , units
                   |> List.map viewHealthbar
                   |> g []
               , units
                   |> List.map (viewCharge game)
                   |> g []
               ]
           ]
       , viewVictory game
       ]
-}
-- Map editor


viewMap : b -> Viewport -> Map -> Svg a
viewMap terrain viewport map =
    Svg.svg [] []



{-
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
-}
