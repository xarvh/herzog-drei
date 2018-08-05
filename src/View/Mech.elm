module View.Mech exposing (..)

import Colors
import Game exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Stats
import Svgl.Tree exposing (..)


-- import View.Propeller


type alias Args =
    { transformState : Float
    , lookAngle : Angle
    , fireAngle : Angle
    , fill : Vec3
    , stroke : Vec3
    , time : Seconds
    }


height =
    Stats.maxHeight.mech



-- Physics


collider : Float -> Angle -> Vec2 -> List Vec2
collider t fireAngle position =
    let
        s =
            smooth t
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
    vec2 -(smooth t 0.13 0.09) (smooth t 0.21 0.26)
        |> Game.rotateVector torsoAngle
        |> Vec2.scale 3


rightGunOffset : Float -> Float -> Vec2
rightGunOffset t torsoAngle =
    vec2 (smooth t 0.13 0.09) (smooth t 0.21 0.26)
        |> Game.rotateVector torsoAngle
        |> Vec2.scale 3



--


type alias ParamsNoColors =
    { x : Float
    , y : Float
    , z : Float
    , a : Float
    , w : Float
    , h : Float
    }


primitiveColor : (Params -> Node) -> Vec3 -> Vec3 -> ParamsNoColors -> Node
primitiveColor primitive fill stroke { x, y, z, a, w, h } =
    primitive
        { defaultParams
            | fill = fill
            , stroke = stroke
            , x = x
            , y = y
            , z = z
            , rotate = degrees a
            , w = w
            , h = h
        }


rectangleColor =
    primitiveColor rect


ellipseColor =
    primitiveColor ellipse


mirrorRectanglesColor : Vec3 -> Vec3 -> ParamsNoColors -> Node
mirrorRectanglesColor fill stroke params =
    Nod
        []
        [ rectangleColor fill stroke { params | x = -params.x, a = -params.a }
        , rectangleColor fill stroke params
        ]


guns : { x : Float, y : Float, w : Float, h : Float } -> Node
guns { x, y, w, h } =
    mirrorRectanglesColor
        Colors.gunFill
        Colors.gunStroke
        { x = x
        , y = y
        , z = 0.9 * height
        , a = 0
        , w = w
        , h = h
        }


eye : { x : Float, y : Float, a : Float } -> Node
eye { x, y, a } =
    ellipse
        { defaultParams
            | fill = Colors.red
            , stroke = Colors.darkRed
            , strokeWidth = 0.02
            , x = x
            , y = y
            , z = height
            , rotate = degrees a
            , w = 0.1
            , h = 0.16
        }



-- Blimp =====================================================================


blimp : Args -> Node
blimp args =
    let
        sm =
            smooth args.transformState

        st =
            step args.transformState 0

        rectangle =
            rectangleColor args.fill args.stroke

        mirrorRectangles =
            mirrorRectanglesColor args.fill args.stroke

        ellipse =
            ellipseColor args.fill args.stroke

        -- Gun covers (ellipses)
        armX =
            0.4

        armY =
            0.2

        armW =
            0.2

        armH =
            0.8

        -- shoulders
        shX =
            0.63

        shY =
            -0.2

        shW =
            0.4

        shH =
            0.6

        shA =
            10
    in
    Nod []
        [ Nod
            [ rotateRad args.fireAngle ]
            [ guns
                { x = sm 0.42 0.25
                , y = sm 0.63 0.3
                , w = sm 0.24 0.15
                , h = 0.9
                }

            -- tail wings
            , mirrorRectangles
                { x = sm 0.3 0.3
                , y = sm -0.15 -0.8
                , z = 0.91 * height
                , w = sm 0.2 0.3
                , h = 0.3
                , a = sm 30 45
                }
            , mirrorRectangles
                { x = sm 0.25 0.35
                , y = sm -0.35 -0.94
                , z = 0.92 * height
                , w = sm 0.45 0.35
                , h = 0.2
                , a = sm -15 0
                }

            -- side mid winglets, gun covers (rectangular)
            , mirrorRectangles
                { x = sm 0.6 0.5
                , y = sm 0.2 0
                , z = 0.93 * height
                , w = sm 0.7 0.5
                , h = sm 0.1 0.3
                , a = sm (80 + 360 * 10) 40
                }

            -- watermelon bottom, right gun cover
            , ellipse
                { x = sm armX 0
                , y = sm armY 0
                , z = 0.94 * height
                , w = sm armW 1.0
                , h = sm armH 2.4
                , a = 0
                }

            -- watermelon mid, left gun cover
            , ellipse
                { x = sm -armX 0
                , y = sm armY 0
                , z = 0.95 * height
                , w = sm armW 0.65
                , h = sm armH 2.4
                , a = 0
                }

            -- watermelon top, mech body
            , ellipse
                { x = 0
                , y = sm -0.1 0
                , z = 0.96 * height
                , w = sm 1.2 0.25
                , h = sm 0.55 2.4
                , a = 0
                }

            -- central tail winglet, shoulders
            , rectangle
                { x = sm shX 0
                , y = sm shY -0.8
                , z = 0.97 * height
                , w = sm shW 0.1
                , h = sm shH 0.3
                , a = sm shA 0
                }
            , rectangle
                { x = sm -shX 0
                , y = sm shY -0.94
                , z = 0.98 * height
                , w = sm shW 0.1
                , h = sm shH 0.2
                , a = sm -shA 0
                }
            ]
        , blimpHead args.transformState args.fill args.stroke (st args.lookAngle args.fireAngle)
        ]


blimpHead : Float -> Vec3 -> Vec3 -> Angle -> Node
blimpHead t fillColor strokeColor angle =
    let
        sm =
            smooth t

        a =
            sm -35 0

        x =
            sm 0.1 0

        y =
            0.35

        h =
            0.2
    in
    Nod
        [ rotateRad angle ]
        -- central mid winglet, head
        [ rectangleColor
            fillColor
            strokeColor
            { x = 0
            , y = 0
            , z = 0.99 * height
            , w = sm 0.4 0.1
            , h = sm 0.9 0.5
            , a = 0
            }
        , eye
            { x = -x
            , y = sm y 0.4
            , a = -a
            }
        , eye
            { x = x
            , y = sm y 0.4
            , a = a
            }
        , eye
            { x = x
            , y = sm (y - h) -0.4
            , a = a
            }
        , eye
            { x = x
            , y = sm (y - 2 * h) -0.4
            , a = a
            }
        , eye
            { x = x
            , y = sm (y - 3 * h) -0.4
            , a = a
            }
        ]



-- Heli ======================================================================


heli : Args -> Node
heli args =
    let
        sm =
            smooth args.transformState

        st =
            step args.transformState 0

        rectangle =
            rectangleColor args.fill args.stroke

        mirrorRectangles =
            mirrorRectanglesColor args.fill args.stroke

        ellipse =
            ellipseColor args.fill args.stroke
    in
    Nod []
        [ Nod
            [ rotateRad args.fireAngle ]
            [ guns
                { x = 0.42
                , y = sm 0.63 0.33
                , w = 0.24
                , h = 0.3
                }

            -- mid winglets
            , mirrorRectangles
                { x = sm 0.5 0.4
                , y = sm 0.3 0.16
                , z = 0.91 * height
                , w = 0.7
                , h = 0.3
                , a = sm -90 20
                }

            -- main heli body
            , ellipse
                { x = 0
                , y = sm -0.04 0
                , z = 0.92 * height
                , w = sm 0.8 0.42
                , h = sm 0.37 1.9
                , a = 0
                }

            -- main mech body
            , ellipse
                { x = 0
                , y = sm -0.04 0
                , z = 0.93 * height
                , w = sm 1.4 0.42
                , h = sm 0.5 0.5
                , a = 0
                }

            -- engine
            , mirrorRectangles
                { x = 0.2
                , y = sm -0.4 0
                , z = 0.94 * height
                , w = 0.2
                , h = sm 0.4 0.68
                , a = 5
                }
            , ellipse
                { x = 0
                , y = sm -0.41 0.1
                , z = 0.95 * height
                , w = 0.3
                , h = sm 0.4 0.7
                , a = 0
                }

            -- tail end
            , mirrorRectangles
                { x = sm -0.55 0.2
                , y = sm -0.05 -1.39
                , z = 0.96 * height
                , w = sm 0.52 0.32
                , h = sm 0.42 0.12
                , a = sm 110 20
                }
            , ellipse
                { x = 0
                , y = sm -0.35 -1.15
                , z = 0.97 * height
                , w = 0.2
                , h = sm 0.2 0.57
                , a = 0
                }
            ]
        , heliHead args.transformState args.fill args.stroke (st args.lookAngle args.fireAngle)

        {-
           , g
               [ transform
                   [ rotateRad args.fireAngle
                   , translate2 0 (sm -0.41 0.1)
                   ]
               ]
               [ View.Propeller.propeller (2.4 * args.transformState) args.time ]
        -}
        ]


heliHead : Float -> Vec3 -> Vec3 -> Angle -> Node
heliHead t fillColor strokeColor angle =
    let
        sm =
            smooth t
    in
    Nod
        [ rotateRad angle ]
        -- cockpit / head
        [ ellipseColor
            fillColor
            strokeColor
            { x = 0
            , y = sm 0.03 0.75
            , z = 0.99 * height
            , w = sm 0.48 0.22
            , h = sm 0.8 0.4
            , a = 0
            }
        , eye
            { x = 0
            , y = sm 0.32 0.85
            , a = sm 0 0
            }
        , eye
            { x = sm -0.14 -0.09
            , y = sm 0.18 0.7
            , a = sm 15 -10
            }
        , eye
            { x = sm 0.14 0.09
            , y = sm 0.18 0.7
            , a = sm -15 10
            }
        ]



-- Plane =====================================================================


plane : Args -> Node
plane args =
    let
        sm =
            smooth args.transformState

        st =
            step args.transformState 0

        rectangle =
            rectangleColor args.fill args.stroke

        mirrorRectangles =
            mirrorRectanglesColor args.fill args.stroke

        ellipse =
            ellipseColor args.fill args.stroke
    in
    Nod []
        [ Nod
            [ rotateRad args.fireAngle ]
            -- guns
            [ guns
                { x = 3 * sm 0.14 0.1
                , y = 3 * sm 0.21 0.26
                , w = 3 * sm 0.08 0.05
                , h = 3 * 0.26
                }

            -- arms / front wings
            , mirrorRectangles
                { x = 3 * sm 0.18 0.25
                , y = 3 * sm 0.1 0.03
                , z = 0.96 * height
                , w = 3 * sm 0.1 0.4
                , h = 3 * sm 0.23 0.15
                , a = sm 0 15
                }

            -- mid beam
            , rectangle
                { x = 0
                , y = 3 * sm -0.04 0.04
                , z = 0.97 * height
                , w = 3 * sm 0.45 0.3
                , h = 3 * sm 0.17 0.12
                , a = 0
                }

            -- shoulders / rear wings
            , mirrorRectangles
                { x = 3 * sm 0.21 0.12
                , y = 3 * sm -0.04 -0.25
                , z = 0.98 * height
                , w = 3 * sm 0.15 0.15
                , h = 3 * sm 0.23 0.25
                , a = sm 10 -45
                }
            ]
        , planeHead args.transformState args.fill args.stroke (st args.lookAngle args.fireAngle)
        ]


planeHead : Float -> Vec3 -> Vec3 -> Angle -> Node
planeHead t fillColor strokeColor angle =
    let
        sm =
            smooth t
    in
    Nod
        [ rotateRad angle ]
        [ ellipseColor
            fillColor
            strokeColor
            { x = 0
            , y = -0.03
            , z = 0.99 * height
            , w = 0.48
            , h = 6 * sm 0.17 0.34
            , a = 0
            }
        , eye { x = 0.09, y = sm 0.3 0.66, a = 14 }
        , eye { x = -0.09, y = sm 0.3 0.66, a = -14 }
        , eye { x = 0.15, y = sm 0.09 0.45, a = 6 }
        , eye { x = -0.15, y = sm 0.09 0.45, a = -6 }
        ]



-- Overlay
{-
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
-}
-- main


mech class =
    case class of
        Plane ->
            plane

        Heli ->
            heli

        Blimp ->
            blimp


head class =
    case class of
        Plane ->
            planeHead

        Heli ->
            heliHead

        Blimp ->
            blimpHead
