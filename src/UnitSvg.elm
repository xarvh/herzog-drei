module UnitSvg exposing (..)

import Game exposing (normalizeAngle)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Svg exposing (..)
import Svg.Attributes exposing (..)


styles =
    String.join ";" >> Svg.Attributes.style


path =
    Svg.path


unit : Float -> Float -> String -> String -> Svg a
unit moveAngle aimAngle brightColor darkColor =
    let
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

        {- TODO
           torsoAngle =
               normalizeAngle (moveAngle + torsoDelta)
        -}
        torsoAngle =
            moveAngle

        a2s angle =
            -angle
                |> Game.radiantsToDegrees
                |> toString

        -- gun origin coordinates
        ( qx, qy ) =
            vec2 0.6 0
                |> Game.rotateVector -torsoAngle
                |> Vec2.toTuple
    in
    g
        [ transform "scale(0.5,-0.5)" ]
        [ rect
            [ transform <| "translate(" ++ toString qx ++ "," ++ toString qy ++ ") rotate(" ++ a2s aimAngle ++ ")"
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
            [ transform <| "rotate(" ++ a2s torsoAngle ++ ")"
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
