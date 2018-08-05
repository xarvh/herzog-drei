module View.Projectile exposing (..)

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
    rect
        { defaultParams
            | fill = yellow
            , stroke = red
            , strokeWidth = 0.015
            , x = Vec2.getX position
            , y = Vec2.getY position
            , z = Stats.maxHeight.projectile
            , rotate = angle
            , w = 0.15
            , h = 0.2
        }


rocket : Vec2 -> Angle -> Vec3 -> Vec3 -> Seconds -> Node
rocket position angle primary secondary time =
    let
        w =
            0.15

        h =
            0.2

        hh =
            h / 2

        exhaust =
            1 + periodLinear time 0 0.1

        params =
            { defaultParams | strokeWidth = 0.01 }
    in
    Nod
        [ translateVz position Stats.maxHeight.projectile, rotateRad angle ]
        [ ellipse
            { params
                | fill = yellow
                , stroke = yellow
                , y = -hh
                , z = 0.01
                , w = w
                , h = exhaust * h
            }
        , ellipse
            { params
                | y = hh
                , z = 0.02
                , w = w
                , h = w
                , fill = secondary
                , stroke = secondary
            }
        , rect
            { params
                | z = 0.03
                , w = w
                , h = h
                , fill = primary
                , stroke = primary
            }
        ]


projectile : ProjectileClassId -> Vec2 -> Angle -> Seconds -> Node
projectile classId position angle t =
    case classId of
        PlaneBullet ->
            bullet position angle

        BigSubBullet ->
            bullet position angle

        HeliRocket ->
            rocket position angle gray black t

        HeliMissile ->
            rocket position angle gray red t

        UpwardSalvo ->
            rocket position angle gray black t

        DownwardSalvo ->
            rocket position angle gray black t
