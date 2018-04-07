module View.Unit exposing (..)

import Game exposing (normalizeAngle, Angle)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Svg exposing (..)
import View exposing (..)


gunOffset : Float -> Vec2
gunOffset torsoAngle =
    vec2 0.3 0 |> Game.rotateVector torsoAngle



-- Unit


unit : Angle -> Angle -> Angle -> String -> String -> Svg a
unit lookAngle moveAngle aimAngle brightColor darkColor =
    let
        {-
           -- aimAngle - moveAngle
           am =
               normalizeAngle (aimAngle - moveAngle)

           -- near threshold
           thn =
               pi / 4

           -- far threshold
           thf =
               pi / 2

           torsoDelta =
               if am < -thf then
                   am + thf
               else if am < -thn then
                   (am + thn) / 2
               else
                   0
        -}
        {- TODO
           torsoAngle =
               normalizeAngle (moveAngle + torsoDelta)
        -}
        gunOrigin =
            gunOffset moveAngle
                |> Vec2.scale 2
    in
    g
        [ transform [ scale 0.5 ] ]
        [ rect
            [ transform [ translate gunOrigin, rotateRad aimAngle ]
            , fill "#808080"
            , stroke "#666"
            , strokeWidth 0.1
            , width 0.42
            , height 2.2
            , x -0.21
            , y -0.7
            ]
            []
        , rect
            [ transform [ rotateRad moveAngle ]
            , height 0.8
            , width 1.8
            , y -0.4
            , x -0.9
            , fill brightColor
            , stroke darkColor
            , strokeWidth 0.1
            ]
            []
        , ellipse
            [ transform [ rotateRad lookAngle ]
            , fill brightColor
            , stroke darkColor
            , strokeWidth 0.1
            , rx 0.5
            , ry 0.6
            ]
            []
        , ellipse
            [ transform [ rotateRad lookAngle ]
            , fill "#f00"
            , stroke "#900"
            , strokeWidth 0.07
            , cy 0.27
            , rx 0.25
            , ry 0.30
            ]
            []
        ]
