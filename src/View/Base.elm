module View.Base exposing (..)

import Game
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Svg exposing (..)
import View exposing (..)


teeth : Float -> Float -> String -> String -> Svg a
teeth completion radius bright dark =
    let
        n =
            30

        amplitude =
            2 * pi / n

        phase =
            2 * pi * completion

        shiftAngle angle =
            angle + amplitude * sin (angle + phase)

        indexToAngle index =
            toFloat index / toFloat n |> turns

        angleToDot angle =
            path
                [ transform [ rotateRad angle, translate2 radius 0, scale 0.15, rotateDeg -90, "scale(0.6,1)" ]
                , d "M0,0 L0,1 L1,0 L1,-1 L-1,-1 L-1,0 Z"
                , fill dark
                , stroke bright
                , strokeWidth 0.3
                ]
                []

        dots =
            List.range 0 (n - 1)
                |> List.map (indexToAngle >> shiftAngle >> angleToDot)
    in
    g
        []
        dots


small : Float -> String -> String -> Svg a
small completion bright dark =
    let
        re xx yy ww hh =
            rect
                [ fill bright
                , stroke dark
                , strokeWidth 0.06
                , width ww
                , height hh
                , x (xx - ww / 2)
                , y (yy - hh / 2)
                ]
                []

        cir xx yy rr =
            circle
                [ fill bright
                , stroke dark
                , strokeWidth 0.08
                , cx xx
                , cy yy
                , r rr
                ]
                []
    in
    g
        []
        [ cir 0 0 1
        , circle
            [ fill dark
            , r (0.6 * completion)
            ]
            []
        , teeth completion 0.7 bright dark
        , re -1 0 0.2 0.4
        , re 1 0.15 0.2 0.15
        , re 1 -0.15 0.2 0.15
        , cir 0.8 0.8 0.4
        , cir -0.8 0.8 0.4
        , cir -0.8 -0.8 0.4
        , cir 0.8 -0.8 0.4
        ]


main_ : Float -> String -> String -> Svg a
main_ completion bright dark =
    let
        re xx yy ww hh =
            rect
                [ fill bright
                , stroke dark
                , strokeWidth 0.08
                , width ww
                , height hh
                , x (xx - ww / 2)
                , y (yy - hh / 2)
                ]
                []

        tri xx yy =
            path
                [ transform [ translate2 xx yy ]
                , fill bright
                , stroke dark
                , strokeWidth 0.03
                , d "M0 0 L-0.4 -0.1 L-0.4 0.1 Z"
                ]
                []

        cir xx yy rr =
            circle
                [ fill bright
                , stroke dark
                , strokeWidth 0.08
                , cx xx
                , cy yy
                , r rr
                ]
                []

        cirtri a =
            cir (1.6 * cos (degrees a)) (1.6 * sin (degrees a)) 0.15

        slowSin =
            sin (2 * pi * completion)

        fastSin =
            sin (4 * pi * (completion + 0.25))
    in
    g
        []
        [ re -1 -1 1.8 1.8
        , re 1 -1 1.8 1.8
        , re 1 1 1.8 1.8
        , re -1 1 1.8 1.8

        --
        , re 0 -1.8 1 0.4
        , re (-1.2 + 0.2 * slowSin) 0 0.2 3

        --
        , tri -1.6 -0.5
        , tri -1.6 -0.8
        , tri -1.6 -1.1

        --
        , tri -1.6 0.5
        , tri -1.6 0.8
        , tri -1.6 1.1

        --
        , re 0.4 (1.4 + 0.1 * slowSin) 0.2 0.5
        , re 0.7 1.4 0.2 0.5
        , re 1.0 (1.4 + 0.1 * fastSin) 0.2 0.5

        -- central static circle
        , cir 0 0 0.5

        -- orthogonal central circles
        , g
            [ transform [ rotateRad (pi * (slowSin - fastSin)) ] ]
            [ re -0.5 0 0.3 0.3
            , re 0 -0.5 0.3 0.3
            , re 0.5 0 0.3 0.3
            , re 0 0.5 0.3 0.3
            ]

        --
        , cir (0.5 * fastSin) (0.5 * slowSin) 0.1
        , cir (0.5 * slowSin) (0.5 * -fastSin) 0.1
        , cir (0.5 * -slowSin) (0.5 * -slowSin) 0.1
        , cir (0.5 * -slowSin) (0.5 * fastSin) 0.1

        -- animated completion
        , circle
            [ fill dark
            , r (0.5 * max 0 (completion - 0.3))
            , opacity 0.7
            ]
            []
        , circle
            [ fill dark
            , r (1.1 * completion)
            , opacity (0.4 + completion / 2)
            ]
            []
        , teeth completion 1.1 dark bright

        --
        , cir 1.8 1.8 0.4
        , cir -1.8 1.8 0.4
        , cir -1.8 -1.8 0.4
        , cir 1.8 -1.8 0.4

        --
        , cirtri -20
        , cirtri (-40 + 5 * fastSin)
        , cirtri -60
        ]
