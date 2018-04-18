module View.Hud exposing (..)

import Game
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Svg exposing (..)
import View exposing (..)


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
            , width (innerWidth * integrity)
            , height innerHeight
            ]
            []
        ]
