module View.Base exposing (..)

import Game
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Svg exposing (..)
import View exposing (..)


small : String -> String -> Svg a
small bright dark =
    rect
        [ fill bright
        , stroke dark
        , strokeWidth 0.02
        , width 2
        , height 2
        , x -1
        , y -1
        ]
        []


main_ : Float -> String -> String -> Svg a
main_ completion bright dark =
    let
        re xx yy ww hh =
            rect
                [ fill bright
                , stroke dark
                , strokeWidth 0.1
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
                , strokeWidth 0.1
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

        --
        , cir 0 0 1.1
        , circle
            [ fill dark
            , r (1.1 * completion)
            ]
            []

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
