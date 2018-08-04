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
import Svgl.Primitives as Primitives exposing (defaultUniforms)
import Svgl.Tree exposing (..)
import Unit
import Update
import View.Base
import View.Gfx
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

        node =
            WebGL.entity quadVertexShader
                rectFragmentShader
                Primitives.normalizedQuadMesh
                { defaultUniforms
                    | entityToCamera = Mat4.scale3 20 5 1 worldToCamera
                }
    in
    [ node ]
        --         |> treeToEntities worldToCamera
        --         |> List.map Tuple.second
        |> WebGL.toHtmlWith
            [ WebGL.alpha True
            , WebGL.antialias
            ]
            (SplitScreen.viewportToWebGLAttributes viewport)


quadVertexShader : Shader Primitives.Attributes Primitives.Uniforms Primitives.Varying
quadVertexShader =
    [glsl|
        precision mediump float;

        attribute vec2 position;

        uniform mat4 entityToCamera;
        uniform vec2 dimensions;
        uniform vec3 fill;
        uniform vec3 stroke;
        uniform float strokeWidth;

        varying vec2 localPosition;

        void main () {
            localPosition = position;
            gl_Position = entityToCamera * vec4(localPosition, 0, 1);
        }
    |]


rectFragmentShader : Shader {} Primitives.Uniforms Primitives.Varying
rectFragmentShader =
    [glsl|
        precision mediump float;

        vec3 random3(vec3 c) {
                float j = 4096.0*sin(dot(c,vec3(17.0, 59.4, 15.0)));
                vec3 r;
                r.z = fract(512.0*j);
                j *= .125;
                r.x = fract(512.0*j);
                j *= .125;
                r.y = fract(512.0*j);
                return r-0.5;
        }

        /* skew constants for 3d simplex functions */
        const float F3 =  0.3333333;
        const float G3 =  0.1666667;

        /* 3d simplex noise */
        float simplex3d(vec3 p) {
                 /* 1. find current tetrahedron T and its four vertices */
                 /* s, s+i1, s+i2, s+1.0 - absolute skewed (integer) coordinates of T vertices */
                 /* x, x1, x2, x3 - unskewed coordinates of p relative to each of T vertices*/

                 /* calculate s and x */
                 vec3 s = floor(p + dot(p, vec3(F3)));
                 vec3 x = p - s + dot(s, vec3(G3));

                 /* calculate i1 and i2 */
                 vec3 e = step(vec3(0.0), x - x.yzx);
                 vec3 i1 = e*(1.0 - e.zxy);
                 vec3 i2 = 1.0 - e.zxy*(1.0 - e);

                 /* x1, x2, x3 */
                 vec3 x1 = x - i1 + G3;
                 vec3 x2 = x - i2 + 2.0*G3;
                 vec3 x3 = x - 1.0 + 3.0*G3;

                 /* 2. find four surflets and store them in d */
                 vec4 w, d;

                 /* calculate surflet weights */
                 w.x = dot(x, x);
                 w.y = dot(x1, x1);
                 w.z = dot(x2, x2);
                 w.w = dot(x3, x3);

                 /* w fades from 0.6 at the center of the surflet to 0.0 at the margin */
                 w = max(0.6 - w, 0.0);

                 /* calculate surflet components */
                 d.x = dot(random3(s), x);
                 d.y = dot(random3(s + i1), x1);
                 d.z = dot(random3(s + i2), x2);
                 d.w = dot(random3(s + 1.0), x3);

                 /* multiply d by w^4 */
                 w *= w;
                 w *= w;
                 d *= w;

                 /* 3. return the sum of the four surflets */
                 return dot(d, vec4(52.0));
        }

        float noise(vec3 m) {
            return   0.5333333*simplex3d(m) +0.2666667*simplex3d(2.0*m) +0.1333333*simplex3d(4.0*m) +0.0666667*simplex3d(8.0*m);
        }


        uniform mat4 entityToCamera;
        uniform vec2 dimensions;
        uniform vec3 fill;
        uniform vec3 stroke;
        uniform float strokeWidth;
        uniform float opacity;

        varying vec2 localPosition;



        void main () {
            vec4 fragColor;
            float iTime = 1000.0;
            float detailDensity = 20.0;

            // point used to get the noise
            vec3 p3 = detailDensity * vec3(localPosition, iTime * 0.4);

            float xx = localPosition.x;
            float yy = localPosition.y;

            // reduce dispersion towards the x extremes
            float reducedX = clamp(-0.46 * xx * xx + 0.15, 0., 1.);

            // ????
            float combinedCoordinates = yy - reducedX * noise(p3);

            // concentrate along the y axis
            float g = pow(combinedCoordinates, 0.2);
            float a = clamp(1.0 - g, 0.0, 1.0);

            vec3 col = a * vec3(1.10, 1.48, 1.78);

            fragColor.rgb = a * col * col * col * col;
            fragColor.a = a - 0.2;

            gl_FragColor = fragColor;}
    |]


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


viewMarker : Game -> Team -> Node
viewMarker game team =
    let
        distance =
            0.5 + 0.25 * periodHarmonic game.time 0 0.3

        angle =
            periodHarmonic game.time 0.1 20 * 180

        params =
            { defaultParams
                | fill = team.colorPattern.darkV
                , stroke = team.colorPattern.brightV
            }

        arrow a =
            Nod
                [ rotateDeg a
                , translate2 0 -distance
                ]
                [ rect
                    { params
                        | w = 0.3
                        , h = 0.3
                    }
                ]
    in
    Nod
        [ translateVz team.markerPosition 0 ]
        [ ellipse
            { params
                | w = 0.5
                , h = 0.6
            }
        , ellipse
            { params
                | y = 0.13
                , w = 0.25
                , h = 0.3
                , strokeWidth = 0.7 * params.strokeWidth
            }
        , arrow (angle + 45)
        , arrow (angle + 135)
        , arrow (angle + 225)
        , arrow (angle + -45)
        ]



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
