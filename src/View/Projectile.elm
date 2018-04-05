module View.Projectile exposing (..)

import Game exposing (Angle)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Svg exposing (..)
import View exposing (..)


projectile : Vec2 -> Angle -> Svg a
projectile position angle =
    let
        ww =
            0.15

        hh =
            0.2
    in
    rect
        [ transform [ translate position, rotateRad angle ]
        , fill "yellow"
        , stroke "red"
        , strokeWidth 0.03
        , width ww
        , height hh
        , x (-ww / 2)
        , y (-hh / 2)
        ]
        []
