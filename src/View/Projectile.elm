module View.Projectile exposing (..)

import ColorPattern exposing (ColorPattern)
import Colors exposing (..)
import Game exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Projectile
import Stats
import Svgl.Tree exposing (..)


yellow =
    vec3 1 1 0


red =
    vec3 1 0 0


gray =
    vec3 0.6 0.6 0.6


black =
    vec3 0 0 0


bullet : Vec2 -> Angle -> Node
bullet position angle =
    ellipse
        { defaultParams
            | fill = yellow
            , stroke = red
            , strokeWidth = 0.015
            , x = Vec2.getX position
            , y = Vec2.getY position
            , z = Stats.maxHeight.projectile
            , rotate = angle
            , w = 0.25
            , h = 0.45
        }


rocket : Vec2 -> Angle -> Vec3 -> Vec3 -> Vec3 -> Seconds -> Node
rocket position angle bodyColor fillColor strokeColor time =
    let
        w =
            0.3

        h =
            0.4

        hh =
            h / 2

        exhaust =
            1 + periodLinear time 0 0.1

        params =
            { defaultParams | strokeWidth = 0.01 }
    in
    Nod
        [ translate position, rotateRad angle ]
        [ ellipse
            { params
                | fill = yellow
                , stroke = yellow
                , y = -hh
                , w = w
                , h = exhaust * h
            }
        , ellipse
            { params
                | y = hh
                , w = w - 0.02
                , h = w
                , fill = fillColor
                , stroke = fillColor
            }
        , rect
            { params
                | w = w
                , h = h
                , fill = bodyColor
                , stroke = bodyColor
            }
        ]


type alias Args =
    { classId : ProjectileClassId
    , position : Vec2
    , angle : Angle
    , age : Seconds
    , colorPattern : ColorPattern
    }


projectile : Args -> Node
projectile { classId, position, angle, age, colorPattern } =
    case classId of
        PlaneBullet ->
            bullet position angle

        BigSubBullet ->
            bullet position angle

        HeliRocket ->
            rocket position angle gray colorPattern.brightV colorPattern.darkV age

        HeliMissile ->
            let
                ( a, b ) =
                    if periodLinear age 0 0.1 > 0.5 then
                        ( white, colorPattern.brightV )
                    else
                        ( colorPattern.darkV, white )
            in
            rocket position angle a b a age

        UpwardSalvo ->
            rocket position angle gray colorPattern.brightV colorPattern.darkV age

        DownwardSalvo ->
            rocket position angle gray colorPattern.brightV colorPattern.darkV age
