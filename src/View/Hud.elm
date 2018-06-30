module View.Hud exposing (..)

import ColorPattern exposing (ColorPattern)
import Game exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Svg exposing (..)
import View exposing (..)


salvoMark : Seconds -> ColorPattern -> Vec2 -> Svg a
salvoMark time { bright, dark } position =
    let
        ( fillColor, strokeColor ) =
            if periodLinear time 0 0.1 > 0.5 then
                ( bright, dark )
            else
                ( dark, bright )

        p =
            Vec2.toRecord position
    in
    Svg.circle
        [ cx p.x
        , cy p.y
        , r 0.1
        , fill fillColor
        , stroke strokeColor
        , strokeWidth 0.03
        ]
        []


chargeBar : Vec2 -> Float -> Svg a
chargeBar unitPosition charge =
    let
        innerHeight =
            0.12

        innerWidth =
            0.95

        border =
            0.08

        color =
            "blue"
    in
    g
        [ transform
            [ translate unitPosition
            , translate2 -(innerWidth / 2) -0.8
            ]
        ]
        [ rect
            [ fill "#222"
            , x -border
            , y -border
            , width (innerWidth + border * 2)
            , height (innerHeight + border * 2)
            ]
            []
        , rect
            [ fill color
            , width (innerWidth * max 0 charge)
            , height innerHeight
            ]
            []
        ]


healthBar : Vec2 -> Float -> Svg a
healthBar unitPosition integrity =
    let
        innerHeight =
            0.12

        innerWidth =
            0.95

        border =
            0.08

        color =
            if integrity > 0.8 then
                "#0d0"
            else if integrity > 0.4 then
                "yellow"
            else
                "red"
    in
    g
        [ transform
            [ translate unitPosition
            , translate2 -(innerWidth / 2) -0.8
            ]
        ]
        [ rect
            [ fill "#222"
            , x -border
            , y -border
            , width (innerWidth + border * 2)
            , height (innerHeight + border * 2)
            ]
            []
        , rect
            [ fill color
            , width (innerWidth * max 0 integrity)
            , height innerHeight
            ]
            []
        ]
