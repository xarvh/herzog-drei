module View.Sub exposing (..)

import Colors
import Game exposing (Angle, normalizeAngle)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
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


sub : Angle -> Angle -> Angle -> Vec3 -> Vec3 -> Bool -> Node
sub lookAngle moveAngle aimAngle brightColor darkColor isBig =
    let
        ( fillColor, strokeColor ) =
            if isBig then
                ( darkColor, brightColor )
            else
                ( brightColor, darkColor )

        gunOrigin =
            gunOffset moveAngle
    in
    Nod
        []
        [ Nod
            -- gun
            [ translate gunOrigin, rotateRad aimAngle ]
            [ rect
                { fill = Colors.gunFill
                , stroke = Colors.gunStroke
                , x = 0
                , y = 0.35
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
                , rotate = 0
                , w = 0.5
                , h = 0.6
                }

            -- eye
            , ellipse
                { fill = Colors.red
                , stroke = Colors.darkRed
                , x = 0
                , y = 0.135
                , rotate = 0
                , w = 0.25
                , h = 0.3
                }
            ]
        ]
