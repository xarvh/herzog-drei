module View.Sub exposing (..)

import Colors
import Game exposing (Angle, normalizeAngle)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Stats
import Svgl.Tree exposing (..)


-- Physics


collider : Angle -> Vec2 -> List Vec2
collider topAngle position =
    [ vec2 -0.5 0.4
    , vec2 0.5 0.4
    , vec2 0.5 -0.4
    , vec2 -0.5 -0.4
    ]
        |> List.map (Game.rotateVector topAngle)
        |> List.map (Vec2.add position)


gunOffset : Float -> Vec2
gunOffset torsoAngle =
    vec2 0.3 0 |> Game.rotateVector torsoAngle



-- Render


type alias Args =
    { lookAngle : Angle
    , moveAngle : Angle
    , fireAngle : Angle
    , bright : Vec3
    , dark : Vec3
    , isBig : Bool
    , isOverBase : Bool
    }


sub : Args -> Node
sub { lookAngle, moveAngle, fireAngle, bright, dark, isBig, isOverBase } =
    let
        ( fillColor, strokeColor ) =
            if isBig then
                ( dark, bright )
            else
                ( bright, dark )

        gunOrigin =
            gunOffset moveAngle

        dz =
            if isOverBase then
                Stats.maxHeight.base
            else
                0

        height =
            Stats.maxHeight.sub
    in
    raiseList dz
        [ Nod
            -- gun
            [ translate gunOrigin, rotateRad fireAngle ]
            [ rect
                { fill = Colors.gunFill
                , stroke = Colors.gunStroke
                , x = 0
                , y = 0.21
                , z = 0.5 * height
                , rotate = 0
                , w = 0.21
                , h = 1.1
                }
            ]
        , Nod
            -- torso
            [ rotateRad moveAngle ]
            [ rect
                { fill = fillColor
                , stroke = strokeColor
                , x = 0
                , y = 0
                , z = 0.7 * height
                , rotate = 0
                , w = 0.9
                , h = 0.4
                }
            ]
        , Nod
            [ rotateRad lookAngle ]
            -- head
            [ ellipse
                { fill = fillColor
                , stroke = strokeColor
                , x = 0
                , y = 0
                , z = 0.9 * height
                , rotate = 0
                , w = 0.5
                , h = 0.6
                }

            -- eye
            , ellipseWithStroke 0.02
                { fill = Colors.red
                , stroke = Colors.darkRed
                , x = 0
                , y = 0.135
                , z = 1.0 * height
                , rotate = 0
                , w = 0.25
                , h = 0.3
                }
            ]
        ]
