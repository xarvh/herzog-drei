module View.Mech exposing (..)

import Colors
import Game exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Svgl.Tree exposing (..)
import View


-- import Game exposing (..)
-- import View.Propeller


type alias Args =
    { transformState : Float
    , lookAngle : Angle
    , fireAngle : Angle
    , fill : Vec3
    , stroke : Vec3
    , time : Seconds
    }


mechHeight =
    0.4


flyingHeight =
    mechHeight



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
        { fill = fill
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
        , z = 0.4 * mechHeight
        , a = 0
        , w = w
        , h = h
        }


eye : { x : Float, y : Float, a : Float } -> Node
eye { x, y, a } =
    ellipseWithStroke 0.02
        { fill = Colors.red
        , stroke = Colors.darkRed
        , x = x
        , y = y
        , z = mechHeight
        , rotate = degrees a
        , w = 0.1
        , h = 0.16
        }


raise : Float -> Node -> Node
raise dz node =
    case node of
        Nod transforms children ->
            Nod transforms (List.map (raise dz) children)

        Ent f ->
            Ent (f >> Tuple.mapFirst ((+) dz))


raiseList : Float -> List Node -> Node
raiseList dz list =
    raise dz (Nod [] list)



-- Blimp =====================================================================


blimp : Args -> Node
blimp args =
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
    raiseList args.transformState
        [ Nod
            [ rotateRad args.fireAngle ]
            [ guns
                { x = smooth 0.42 0.25
                , y = smooth 0.63 0.3
                , w = smooth 0.24 0.15
                , h = 0.9
                }

            -- tail wings
            , mirrorRectangles
                { x = smooth 0.3 0.3
                , y = smooth -0.15 -0.8
                , z = 0.41 * mechHeight
                , w = smooth 0.2 0.3
                , h = 0.3
                , a = smooth 30 45
                }
            , mirrorRectangles
                { x = smooth 0.25 0.35
                , y = smooth -0.35 -0.94
                , z = 0.42 * mechHeight
                , w = smooth 0.45 0.35
                , h = 0.2
                , a = smooth -15 0
                }

            -- side mid winglets, gun covers (rectangular)
            , mirrorRectangles
                { x = smooth 0.6 0.5
                , y = smooth 0.2 0
                , z = 0.43 * mechHeight
                , w = smooth 0.7 0.5
                , h = smooth 0.1 0.3
                , a = smooth (80 + 360 * 10) 40
                }

            -- watermelon bottom, right gun cover
            , ellipse
                { x = smooth armX 0
                , y = smooth armY 0
                , z = 0.44 * mechHeight
                , w = smooth armW 1.0
                , h = smooth armH 2.4
                , a = 0
                }

            -- watermelon mid, left gun cover
            , ellipse
                { x = smooth -armX 0
                , y = smooth armY 0
                , z = 0.45 * mechHeight
                , w = smooth armW 0.65
                , h = smooth armH 2.4
                , a = 0
                }

            -- watermelon top, mech body
            , ellipse
                { x = 0
                , y = smooth -0.1 0
                , z = 0.46 * mechHeight
                , w = smooth 1.2 0.25
                , h = smooth 0.55 2.4
                , a = 0
                }

            -- central tail winglet, shoulders
            , rectangle
                { x = smooth shX 0
                , y = smooth shY -0.8
                , z = 0.47 * mechHeight
                , w = smooth shW 0.1
                , h = smooth shH 0.3
                , a = smooth shA 0
                }
            , rectangle
                { x = smooth -shX 0
                , y = smooth shY -0.94
                , z = 0.48 * mechHeight
                , w = smooth shW 0.1
                , h = smooth shH 0.2
                , a = smooth -shA 0
                }
            ]
        , blimpHead args.transformState args.fill args.stroke (step args.lookAngle args.fireAngle)
        ]


blimpHead : Float -> Vec3 -> Vec3 -> Angle -> Node
blimpHead t fillColor strokeColor angle =
    let
        smooth =
            View.smooth t

        a =
            smooth -35 0

        x =
            smooth 0.1 0

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
            , z = 0.99 * mechHeight
            , w = smooth 0.4 0.1
            , h = smooth 0.9 0.5
            , a = 0
            }
        , eye
            { x = -x
            , y = smooth y 0.4
            , a = -a
            }
        , eye
            { x = x
            , y = smooth y 0.4
            , a = a
            }
        , eye
            { x = x
            , y = smooth (y - h) -0.4
            , a = a
            }
        , eye
            { x = x
            , y = smooth (y - 2 * h) -0.4
            , a = a
            }
        , eye
            { x = x
            , y = smooth (y - 3 * h) -0.4
            , a = a
            }
        ]



{-
   -- Heli ======================================================================


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
                   { x = 0.42
                   , y = smooth 0.63 0.33
                   , w = 0.24
                   , h = 0.3
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



   -- Plane =====================================================================


   plane : Args -> Svg a
   plane args =
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
               -- guns
               [ guns
                   { x = 3 * smooth 0.14 0.1
                   , y = 3 * smooth 0.21 0.26
                   , w = 3 * smooth 0.08 0.05
                   , h = 3 * 0.26
                   }

               -- arms / front wings
               , mirrorRectangles
                   { x = 3 * smooth 0.18 0.25
                   , y = 3 * smooth 0.1 0.03
                   , w = 3 * smooth 0.1 0.4
                   , h = 3 * smooth 0.23 0.15
                   , a = smooth 0 15
                   }

               -- mid beam
               , rectangle
                   { x = 0
                   , y = 3 * smooth -0.04 0.04
                   , w = 3 * smooth 0.45 0.3
                   , h = 3 * smooth 0.17 0.12
                   , a = 0
                   }

               -- shoulders / rear wings
               , mirrorRectangles
                   { x = 3 * smooth 0.21 0.12
                   , y = 3 * smooth -0.04 -0.25
                   , w = 3 * smooth 0.15 0.15
                   , h = 3 * smooth 0.23 0.25
                   , a = smooth 10 -45
                   }
               ]
           , planeHead args.transformState args.fill args.stroke (step args.lookAngle args.fireAngle)
           ]


   planeHead : Float -> String -> String -> Angle -> Svg a
   planeHead t fillColor strokeColor angle =
       let
           smooth =
               View.smooth t
       in
       g
           [ transform [ rotateRad angle ] ]
           [ ellipseColor
               fillColor
               strokeColor
               { x = 0
               , y = -0.03
               , w = 0.48
               , h = 6 * smooth 0.17 0.34
               }
           , eye { x = 0.09, y = smooth 0.3 0.66, a = 14 }
           , eye { x = -0.09, y = smooth 0.3 0.66, a = -14 }
           , eye { x = 0.15, y = smooth 0.09 0.45, a = 6 }
           , eye { x = -0.15, y = smooth 0.09 0.45, a = -6 }
           ]

-}
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
            blimp

        Heli ->
            blimp

        Blimp ->
            blimp


head class =
    case class of
        Plane ->
            blimpHead

        Heli ->
            blimpHead

        Blimp ->
            blimpHead
