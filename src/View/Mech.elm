module View.Mech exposing (..)

import Game exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Svg exposing (..)
import View exposing (..)
import View.Propeller


{-| TODO: this should go inside View
-}
strokeW : Svg.Attribute a
strokeW =
    strokeWidth 0.06


type alias Args =
    { transformState : Float
    , lookAngle : Angle
    , fireAngle : Angle
    , fill : String
    , stroke : String
    , time : Seconds
    }



-- Physics


collider : Float -> Angle -> Vec2 -> List Vec2
collider t fireAngle position =
    let
        s =
            View.smooth t
    in
    [ vec2 (s -0.8 -0.5) (s -0.4 -0.9)
    , vec2 (s -0.7 -0.5) (s 0.6 0.9)
    , vec2 (s 0.7 0.5) (s 0.6 0.9)
    , vec2 (s 0.8 0.5) (s -0.4 -0.9)
    ]
        |> List.map (Game.rotateVector fireAngle)
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



-- draw helpers (chuck these in View too?)


type alias RectangleArgs =
    { x : Float
    , y : Float
    , w : Float
    , h : Float
    , a : Float
    }


rectangleColor : String -> String -> RectangleArgs -> Svg a
rectangleColor fillColor strokeColor ar =
    rect
        [ transform [ translate2 ar.x ar.y, rotateDeg ar.a ]
        , fill fillColor
        , stroke strokeColor
        , strokeW
        , width ar.w
        , height ar.h
        , x (-ar.w / 2)
        , y (-ar.h / 2)
        ]
        []


mirrorRectanglesColor : String -> String -> RectangleArgs -> Svg a
mirrorRectanglesColor fillColor strokeColor ar =
    g []
        [ rectangleColor fillColor strokeColor { ar | x = -ar.x, a = -ar.a }
        , rectangleColor fillColor strokeColor ar
        ]


ellipseColor : String -> String -> { x : Float, y : Float, w : Float, h : Float } -> Svg a
ellipseColor fillColor strokeColor ar =
    Svg.ellipse
        [ cx ar.x
        , cy ar.y
        , rx (ar.w / 2)
        , ry (ar.h / 2)
        , fill fillColor
        , stroke strokeColor
        , strokeW
        ]
        []


guns : { x : Float, y : Float, w : Float, h : Float } -> Svg a
guns ar =
    mirrorRectanglesColor "#666" "#808080" { x = ar.x, y = ar.y, w = ar.w, h = ar.h, a = 0 }


eye : { x : Float, y : Float, a : Float } -> Svg a
eye ar =
    Svg.ellipse
        [ transform [ translate2 ar.x ar.y, rotateDeg ar.a ]
        , fill "#f80000"
        , stroke "#990000"
        , strokeWidth 0.03
        , ry 0.08
        , rx 0.05
        ]
        []



-- Heli


heli : Args -> Svg a
heli args =
    let
        smooth =
            View.smooth args.transformState

        step =
            View.step args.transformState 0

        rectangle =
            rectangleColor args.fill args.stroke

        mirrorRectangles =
            mirrorRectanglesColor args.fill args.stroke

        ellipse =
            ellipseColor args.fill args.stroke
    in
    g []
        [ g
            [ transform [ rotateRad args.fireAngle ] ]
            [ guns
                { x = smooth 0.42 0.3
                , y = smooth 0.63 0.33
                , w = smooth 0.24 0.15
                , h = 0.68
                }

            -- mid winglets
            , mirrorRectangles
                { x = smooth 0.5 0.4
                , y = smooth 0.3 0.16
                , w = 0.7
                , h = 0.3
                , a = smooth -90 20
                }

            -- main heli body
            , ellipse
                { x = 0
                , y = smooth -0.04 0
                , w = smooth 0.8 0.42
                , h = smooth 0.37 1.9
                }

            -- main mech body
            , ellipse
                { x = 0
                , y = smooth -0.04 0
                , w = smooth 1.4 0.42
                , h = smooth 0.5 0.5
                }

            -- engine
            , mirrorRectangles
                { x = 0.2
                , y = smooth -0.4 0
                , w = 0.2
                , h = smooth 0.4 0.68
                , a = 5
                }
            , ellipse
                { x = 0
                , y = smooth -0.41 0.1
                , w = 0.3
                , h = smooth 0.4 0.7
                }

            -- tail end
            , mirrorRectangles
                { x = smooth -0.55 0.2
                , y = smooth -0.05 -1.39
                , w = smooth 0.52 0.32
                , h = smooth 0.42 0.12
                , a = smooth 110 20
                }
            , ellipse
                { x = 0
                , y = smooth -0.35 -1.15
                , w = 0.2
                , h = smooth 0.2 0.57
                }
            ]
        , heliHead args.transformState args.fill args.stroke (step args.lookAngle args.fireAngle)
        , g
            [ transform
                [ rotateRad args.fireAngle
                , translate2 0 (smooth -0.41 0.1)
                ]
            ]
            [ View.Propeller.propeller (2.4 * args.transformState) args.time ]
        ]


heliHead : Float -> String -> String -> Angle -> Svg a
heliHead t fillColor strokeColor angle =
    let
        smooth =
            View.smooth t
    in
    g
        [ transform [ rotateRad angle ] ]
        -- cockpit / head
        [ ellipseColor
            fillColor
            strokeColor
            { x = 0
            , y = smooth 0.03 0.75
            , w = smooth 0.48 0.22
            , h = smooth 0.8 0.4
            }
        , eye
            { x = 0
            , y = smooth 0.32 0.85
            , a = smooth 0 0
            }
        , eye
            { x = smooth -0.14 -0.09
            , y = smooth 0.18 0.7
            , a = smooth 15 -10
            }
        , eye
            { x = smooth 0.14 0.09
            , y = smooth 0.18 0.7
            , a = smooth -15 10
            }
        ]



-- Render


plane : Args -> Svg a
plane args =
    let
        smooth =
            View.smooth args.transformState

        step =
            View.step args.transformState 0

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
                [ rectPlate args.fill args.stroke -xx yy ww hh -aa
                , rectPlate args.fill args.stroke xx yy ww hh aa
                ]
    in
    g []
        [ g
            [ transform [ scale 3, rotateRad args.fireAngle ] ]
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
                args.fill
                args.stroke
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
        , planeHead args.transformState args.fill args.stroke (step args.lookAngle args.fireAngle)
        ]


planeHead : Float -> String -> String -> Angle -> Svg a
planeHead t fillColor strokeColor angle =
    let
        smooth =
            View.smooth t

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
    g
        [ transform [ scale 3, rotateRad angle ] ]
        [ ellipse
            [ cx 0
            , cy -0.01
            , rx 0.08
            , ry <| smooth 0.17 0.34
            , fill fillColor
            , stroke strokeColor
            , strokeWidth 0.02
            ]
            []
        , eye 0.03 (smooth 0.1 0.22) 14
        , eye -0.03 (smooth 0.1 0.22) -14
        , eye 0.05 (smooth 0.03 0.15) 6
        , eye -0.05 (smooth 0.03 0.15) -6
        ]



-- Overlay


headOverlay : Float -> Angle -> Svg a
headOverlay op angle =
    g
        [ transform [ scale 3, rotateRad angle ]
        , opacity op
        ]
        [ ellipse
            [ cx 0
            , cy -0.01
            , rx 0.08
            , ry 0.17
            , fill "#fff"
            ]
            []
        ]



-- main


mech class =
    case class of
        Plane ->
            plane

        Heli ->
            heli


head class =
    case class of
        Plane ->
            planeHead

        Heli ->
            heliHead
