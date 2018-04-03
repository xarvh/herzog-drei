module View.Mech exposing (..)

import Game exposing (normalizeAngle)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Svg exposing (..)
import View exposing (..)


-- Mech
{-
   gunOffset : Float -> Vec2
   gunOffset torsoAngle =
       vec2 0.3 0 |> Game.rotateVector torsoAngle
-}


mech : Float -> Float -> Float -> String -> String -> Svg a
mech t headAngle topAngle brightColor darkColor =
    let
        smooth =
            View.smooth t

        step =
            View.step t

        rectPlate fillColor xx yy ww hh aa =
            rect
                [ transform [ translate2 xx yy, rotateDeg aa ]
                , fill fillColor
                , stroke brightColor
                , strokeWidth 0.03
                , width ww
                , height hh
                , x (-ww / 2)
                , y (-hh / 2)
                ]
                []

        plates xx yy ww hh aa =
            g []
                [ rectPlate darkColor -xx yy ww hh -aa
                , rectPlate darkColor xx yy ww hh aa
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
            [ rectPlate "#808080" -(smooth 0.39 0.15) (smooth 0.21 0.26) 0.08 0.26 -0
            , rectPlate "#808080" (smooth 0.39 0.15) (smooth 0.21 0.26) 0.08 0.26 0

            -- arms / front wings
            , plates
                (smooth 0.35 0.25)
                (smooth 0.02 0.03)
                (smooth 0.2 0.4)
                (smooth 0.23 0.15)
                (smooth 0 15)

            -- mid beam
            , rectPlate
                darkColor
                0
                (smooth -0.04 0.04)
                (smooth 0.65 0.3)
                (smooth 0.17 0.12)
                0

            -- shoulders / rear wings
            , plates
                (smooth 0.29 0.12)
                (smooth -0.04 -0.25)
                (smooth 0.2 0.15)
                (smooth 0.23 0.25)
                (smooth 0 -45)
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
                , strokeWidth 0.03
                ]
                []
            , eye 0.03 (smooth 0.1 0.22) 14
            , eye -0.03 (smooth 0.1 0.22) -14
            , eye 0.05 (smooth 0.03 0.15) 6
            , eye -0.05 (smooth 0.03 0.15) -6
            ]
        ]
