module View.Mech exposing (..)

import Game exposing (Angle)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Svg exposing (..)
import View exposing (..)


-- Physics


collider : Float -> Angle -> Vec2 -> List Vec2
collider t topAngle position =
    let
        s =
            View.smooth t
    in
    [ vec2 (s -0.8 -0.5) (s -0.4 -0.9)
    , vec2 (s -0.7 -0.5) (s 0.6 0.9)
    , vec2 (s 0.7 0.5) (s 0.6 0.9)
    , vec2 (s 0.8 0.5) (s -0.4 -0.9)
    ]
        |> List.map (Game.rotateVector topAngle)
        |> List.map (Vec2.add position)


leftGunOffset : Float -> Float -> Vec2
leftGunOffset t torsoAngle =
    vec2 -(View.smooth t 0.13 0.09) (View.smooth t 0.21 0.26)
        |> Game.rotateVector torsoAngle
        |> Vec2.scale 3


rightGunOffset : Float -> Float -> Vec2
rightGunOffset t torsoAngle =
    vec2 (View.smooth t 0.13 0.09) (View.smooth t 0.21 0.26)
        |> Game.rotateVector torsoAngle
        |> Vec2.scale 3



-- Render


mech : Float -> Angle -> Angle -> String -> String -> Svg a
mech t headAngle topAngle darkColor brightColor =
    let
        smooth =
            View.smooth t

        step =
            View.step t

        rectPlate strokeColor fillColor xx yy ww hh aa =
            rect
                [ transform [ translate2 xx yy, rotateDeg aa ]
                , fill fillColor
                , stroke strokeColor
                , strokeWidth 0.02
                , width ww
                , height hh
                , x (-ww / 2)
                , y (-hh / 2)
                ]
                []

        plates xx yy ww hh aa =
            g []
                [ rectPlate brightColor darkColor -xx yy ww hh -aa
                , rectPlate brightColor darkColor xx yy ww hh aa
                ]

        eye xx yy aa =
            ellipse
                [ transform [ translate2 xx yy, rotateDeg aa ]
                , fill "#f80000"
                , stroke "#990000"
                , strokeWidth 0.01
                , ry 0.027
                , rx 0.018
                ]
                []
    in
    g []
        [ g
            [ transform [ scale 3, rotateRad topAngle ] ]
            -- guns
            [ rectPlate "#666" "#808080" -(smooth 0.14 0.1) (smooth 0.21 0.26) (smooth 0.08 0.05) 0.26 0
            , rectPlate "#666" "#808080" (smooth 0.14 0.1) (smooth 0.21 0.26) (smooth 0.08 0.05) 0.26 0

            -- arms / front wings
            , plates
                (smooth 0.18 0.25)
                (smooth 0.1 0.03)
                (smooth 0.1 0.4)
                (smooth 0.23 0.15)
                (smooth 0 15)

            -- mid beam
            , rectPlate
                brightColor
                darkColor
                0
                (smooth -0.04 0.04)
                (smooth 0.45 0.3)
                (smooth 0.17 0.12)
                0

            -- shoulders / rear wings
            , plates
                (smooth 0.21 0.12)
                (smooth -0.04 -0.25)
                (smooth 0.15 0.15)
                (smooth 0.23 0.25)
                (smooth 10 -45)
            ]
        , g
            [ transform [ scale 3, rotateRad (step headAngle topAngle) ] ]
            [ ellipse
                [ cx 0
                , cy -0.01
                , rx 0.08
                , ry <| smooth 0.17 0.34
                , fill darkColor
                , stroke brightColor
                , strokeWidth 0.02
                ]
                []
            , eye 0.03 (smooth 0.1 0.22) 14
            , eye -0.03 (smooth 0.1 0.22) -14
            , eye 0.05 (smooth 0.03 0.15) 6
            , eye -0.05 (smooth 0.03 0.15) -6
            ]
        ]



-- Mantis


mantis : Float -> Angle -> Angle -> String -> String -> Svg a
mantis t headAngle topAngle darkColor brightColor =
    let
        smooth =
            View.smooth t

        step =
            View.step t

        --
        torsoA =
            -45

        leftShoulderA =
            60

        leftElbowA =
            -10

        leftWristA =
            -20

        --
        rectPlate ( xx, yy ) ( ww, hh ) =
            rect
                [ transform [ translate2 xx yy ]
                , fill darkColor
                , stroke brightColor
                , strokeWidth 0.06
                , width ww
                , height hh
                , x (-ww / 2)
                , y (-hh / 2)
                ]
                []

        eye xx yy aa =
            ellipse
                [ transform [ translate2 xx yy, rotateDeg aa ]
                , fill "#f80000"
                , stroke "#990000"
                , strokeWidth 0.03
                , ry 0.081
                , rx 0.06
                ]
                []
    in
    g []
        -- torso + arms
        [ g
            [ transform
                [ rotateDeg torsoA ]
            ]
            [ rectPlate ( 0, 0 ) ( 1.35, 0.51 )
            , g
                [ transform
                    [ translate2 -0.7 0
                    , rotateDeg leftShoulderA
                    ]
                ]
                [ rectPlate ( -0.5, 0 ) ( 1, 0.4 )
                , g
                ]
            ]

        -- head
        , g
            [ transform [ rotateRad (step headAngle topAngle) ] ]
            [ ellipse
                [ cx 0
                , cy -0.03
                , rx 0.24
                , ry 0.51
                , fill darkColor
                , stroke brightColor
                , strokeWidth 0.06
                ]
                []
            , eye 0.09 0.3 14
            , eye -0.09 0.3 -14
            , eye 0.15 0.09 6
            , eye -0.15 0.09 -6
            ]
        ]
