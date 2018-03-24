module UnitSvg exposing (..)

import Ease
import Game exposing (normalizeAngle)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Svg exposing (..)
import Svg.Attributes exposing (..)


styles =
    String.join ";" >> Svg.Attributes.style


path =
    Svg.path



--


gunOffset : Float -> Vec2
gunOffset torsoAngle =
    vec2 0.3 0 |> Game.rotateVector torsoAngle



-- Laser


laserLifeSpan : Float
laserLifeSpan =
    2.0


laser : Vec2 -> Vec2 -> String -> Float -> Svg a
laser start end color age =
    let
        t =
            age / laserLifeSpan
    in
    line
        [ start |> Vec2.getX |> toString |> x1
        , start |> Vec2.getY |> toString |> y1
        , end |> Vec2.getX |> toString |> x2
        , end |> Vec2.getY |> toString |> y2
        , styles
            [ "stroke-width:" ++ toString (0.1 * (1 + 3 * t))
            , "stroke:" ++ color
            , "opacity:" ++ toString (1 - Ease.outExpo t)
            ]
        ]
        []



-- Unit


unit : Float -> Float -> String -> String -> Svg a
unit moveAngle aimAngle brightColor darkColor =
    let
        {-
           -- aimAngle - moveAngle
           am =
               normalizeAngle (aimAngle - moveAngle)

           -- near threshold
           thn =
               pi / 4

           -- far threshold
           thf =
               pi / 2

           torsoDelta =
               if am < -thf then
                   am + thf
               else if am < -thn then
                   (am + thn) / 2
               else
                   0
        -}
        {- TODO
           torsoAngle =
               normalizeAngle (moveAngle + torsoDelta)
        -}
        a2s angle =
            angle
                |> Game.radiantsToDegrees
                |> toString

        -- gun origin coordinates
        ( gx, gy ) =
            gunOffset moveAngle
                |> Vec2.scale 2
                |> Vec2.toTuple
    in
    g
        [ transform "scale(0.5,-0.5)" ]
        [ rect
            [ transform <| "translate(" ++ toString gx ++ "," ++ toString -gy ++ ") rotate(" ++ a2s aimAngle ++ ")"
            , styles
                [ "fill:#808080"
                , "stroke:" ++ darkColor
                , "stroke-width:0.1"
                ]
            , width "0.42"
            , height "2.2"
            , x "-0.21"
            , y "-1.5"
            ]
            []
        , rect
            [ transform <| "rotate(" ++ a2s moveAngle ++ ")"
            , height "0.8"
            , width "1.8"
            , y "-0.4"
            , x "-0.9"
            , styles
                [ "fill:" ++ brightColor
                , "stroke:" ++ darkColor
                , "stroke-width:0.1"
                ]
            ]
            []
        , path
            [ styles
                [ "fill:" ++ darkColor
                , "stroke-width:1"
                ]
            , d "m 13.630746,283.43605 -5.7519528,-0.10121 -1.6812025,-5.5017 4.7129133,-3.29904 4.593943,3.46279 z"
            , transform <| "rotate(" ++ a2s aimAngle ++ ") translate(0,-272.13998) matrix(0.11036153,0,0,0.17636706,-1.1985001,222.90086)"
            ]
            []
        , ellipse
            [ transform <| "rotate(" ++ a2s aimAngle ++ ")"
            , styles
                [ "fill:#f00"
                , "stroke-width:0.07"
                ]
            , cx "-0.0097503308"
            , cy "-0.26726999999999634"
            , rx "0.25477111"
            , ry "0.30572531"
            ]
            []
        ]
