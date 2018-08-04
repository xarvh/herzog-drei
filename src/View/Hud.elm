module View.Hud exposing (..)

import ColorPattern exposing (ColorPattern)
import Colors exposing (..)
import Game exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Svgl.Tree exposing (..)


-- Bars


chargeBar : Float -> Node
chargeBar charge =
    Nod
        [ translate2 0 -0.65 ]
        (bar blue charge)


healthBar : Float -> Node
healthBar integrity =
    let
        color =
            if integrity > 0.8 then
                green
            else if integrity > 0.4 then
                yellow
            else
                red
    in
    Nod
        [ translate2 0 -0.8 ]
        (bar color integrity)


bar : Vec3 -> Float -> List Node
bar color completion =
    let
        h =
            0.15

        w =
            0.95

        border =
            0.025

        frameColor =
            grey 0.15
    in
    [ rect
        { defaultParams
            | fill = frameColor
            , stroke = frameColor
            , strokeWidth = border
            , w = w
            , h = h
        }
    , rect
        { defaultParams
            | fill = color
            , stroke = frameColor
            , strokeWidth = border
            , x = border - w * (1 - completion) / 2
            , w = w * completion
            , h = h
        }
    ]



-- Heli salvo marks


salvoMark : Seconds -> ColorPattern -> Vec2 -> Node
salvoMark time { brightV, darkV } position =
    let
        ( fillColor, strokeColor ) =
            if periodLinear time 0 0.1 > 0.5 then
                ( brightV, darkV )
            else
                ( darkV, brightV )

        p =
            Vec2.toRecord position
    in
    ellipse
        { defaultParams
            | fill = fillColor
            , stroke = strokeColor
            , strokeWidth = 0.03
            , x = p.x
            , y = p.y
            , w = 0.2
            , h = 0.2
        }
