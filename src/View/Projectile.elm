module View.Projectile exposing (..)

import Game exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Projectile
import Svg exposing (..)
import View exposing (..)


bullet : Vec2 -> Angle -> Svg a
bullet position angle =
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


rocket : Vec2 -> Angle -> String -> String -> Seconds -> Float -> Svg a
rocket position angle primary secondary time scaleF =
    let
        w =
            0.15

        h =
            0.2

        hw =
            w / 2

        hh =
            h / 2

        exhaust =
            0.5 * (1 + periodLinear time 0 0.1)
    in
    g
        [ transform [ translate position, rotateRad angle, scale scaleF ] ]
        [ ellipse
            [ cy -hh
            , rx hw
            , ry (exhaust * h)
            , fill "yellow"
            ]
            []
        , circle
            [ cy hh
            , r hw
            , fill secondary
            ]
            []
        , rect
            [ x -hw
            , y -hh
            , width w
            , height h
            , fill primary
            ]
            []
        ]


projectile : ProjectileClassId -> Vec2 -> Angle -> Seconds -> Svg a
projectile classId position angle t =
    case classId of
        PlaneBullet ->
            bullet position angle

        BigSubBullet ->
            bullet position angle

        HeliRocket ->
            rocket position angle "#bbb" "red" t 1

        UpwardSalvo ->
            rocket position angle "#bbb" "red" t (Projectile.perspective t)

        DownwardSalvo ->
            rocket position angle "#bbb" "red" t (Projectile.perspective t)
