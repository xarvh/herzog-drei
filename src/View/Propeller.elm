module View.Propeller exposing (..)

import Game exposing (..)
import Svg exposing (..)
import Svg.Attributes as SA
import View exposing (..)


bladeLength : Float
bladeLength =
    0.5


blade : Angle -> Svg a
blade angle =
    g
        [ transform [ rotateDeg angle ]
        , SA.filter "url(#blur)"
        ]
        [ Svg.rect
            [ width 0.025
            , x -0.0125
            , height bladeLength
            , fill "url(#bladeRect)"
            , stroke "none"
            ]
            []
        , Svg.path
            [ roundArcD bladeLength (7 * pi / 12) (5 * pi / 12)
            , fill "url(#bladeArc)"
            , stroke "none"
            ]
            []
        ]


propeller : Float -> Seconds -> Svg a
propeller size time =
    let
        -- degrees per second
        speed =
            1000

        v =
            time * speed

        angleInDeg =
            toFloat (modBy 360 (floor v))
    in
    g
        [ transform [ scale size ] ]
        [ defs
            []
            [ Svg.filter
                [ SA.id "blur" ]
                [ feGaussianBlur
                    [ SA.result "blur"
                    , SA.stdDeviation "0.008 0"
                    ]
                    []
                ]
            , Svg.radialGradient
                [ SA.id "bladeRect"
                , cx 0.5
                , cy 0
                , r 0.8
                ]
                [ Svg.stop [ SA.offset "0%", SA.stopOpacity "1" ] []
                , Svg.stop [ SA.offset "100%", SA.stopOpacity "0" ] []
                ]
            , Svg.radialGradient
                [ SA.id "bladeArc"
                , cx 0.5
                , cy 0
                , r 0.8
                ]
                [ Svg.stop [ SA.offset "0%", SA.stopOpacity "0" ] []
                , Svg.stop [ SA.offset "100%", SA.stopOpacity "0.1" ] []
                ]
            ]
        , g
            [ transform [ rotateDeg angleInDeg ]
            ]
            [ blade 0
            , blade 72
            , blade 144
            , blade 216
            , blade 288
            , circle
                [ r bladeLength
                , opacity 0.05
                ]
                []
            ]
        ]
