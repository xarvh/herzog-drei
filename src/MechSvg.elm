module MechSvg exposing (..)

import Ease
import Game exposing (normalizeAngle)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Svg exposing (..)
import Svg.Attributes as SA exposing (transform)


styles =
    String.join ";" >> SA.style


path =
    Svg.path


a2s : Float -> String
a2s angle =
    -angle
        |> Game.radiantsToDegrees
        |> toString


x =
    toString >> SA.x


y =
    toString >> SA.y


rx =
    toString >> SA.rx


ry =
    toString >> SA.ry


cx =
    toString >> SA.cx


cy =
    toString >> SA.cy


width =
    toString >> SA.width


height =
    toString >> SA.height



-- Mech
{-
   gunOffset : Float -> Vec2
   gunOffset torsoAngle =
       vec2 0.3 0 |> Game.rotateVector torsoAngle
-}


mech : Float -> Float -> Float -> String -> String -> Svg a
mech t headAngle topAngle brightColor darkColor =
    let
        smooth : Float -> Float -> Float
        smooth a b =
            let
                tt =
                    Ease.inOutCubic t
            in
            tt * b + (1 - tt) * a

        step : Float -> Float -> Float
        step a b =
            if t > 0 then
                b
            else
                a

        bodyStyle =
            styles
                [ "fill:" ++ darkColor
                , "stroke:" ++ brightColor
                , "stroke-width:0.03"
                ]

        eyesStyle =
            styles
                [ "fill:#f80000"
                , "stroke:#ff8383"
                , "stroke-width:0.00553906"
                ]

        plate xx yy ww hh aa =
            rect
                [ transform <| "translate(" ++ toString xx ++ "," ++ toString yy ++ ") rotate(" ++ toString aa ++ ")"
                , bodyStyle
                , width ww
                , height hh
                , x (-ww / 2)
                , y (-hh / 2)
                ]
                []

        plates xx yy ww hh aa =
            g []
                [ plate -xx yy ww hh -aa
                , plate xx yy ww hh aa
                ]

        eye xx yy aa =
            ellipse
                [ transform <| "translate(" ++ toString xx ++ "," ++ toString yy ++ ") rotate(" ++ toString aa ++ ")"
                , eyesStyle
                , ry 0.027
                , rx 0.018
                ]
                []
    in
    g []
        [ g
            [ transform <| "scale(3,3) rotate(" ++ a2s topAngle ++ ")" ]
            -- guns
            [ plates (smooth 0.39 0.15) (smooth 0.21 0.26) 0.08 0.26 0

            -- arms / front wings
            , plates
                (smooth 0.35 0.25)
                (smooth 0.02 0.03)
                (smooth 0.2 0.4)
                (smooth 0.23 0.15)
                (smooth 0 -15)

            -- mid beam
            , plate
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
                (smooth 0 45)
            ]
        , g
            [ transform <| "scale(3,3) rotate(" ++ a2s (step headAngle topAngle) ++ ")" ]
            [ ellipse
                [ cx 0
                , cy -0.01
                , rx 0.08
                , ry <| smooth 0.17 0.34
                , bodyStyle
                ]
                []
            , eye 0.03 (smooth 0.1 0.22) 14
            , eye -0.03 (smooth 0.1 0.22) -14
            , eye 0.05 (smooth 0.03 0.15) 6
            , eye -0.05 (smooth 0.03 0.15) -6
            ]
        ]
