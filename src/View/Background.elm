module View.Background exposing (..)

import Game exposing (Seconds)
import Svg exposing (..)
import Svg.Attributes exposing (..)

-- https://stackoverflow.com/questions/32858120/svg-pattern-animation
-- https://www.hongkiat.com/blog/svg-animations/

terrain : Seconds -> Svg a
terrain time =
    g
        []
        [ defs
            []
            [ pattern
                [ id "hex-background"
                , width "0.56"
                , height "1"
                , patternUnits "userSpaceOnUse"
                , patternTransform "scale(1)"
                ]
                [ rect
                    [ width "56"
                    , height "100"
                    , fill "green"
                    , stroke "purple"
                    , strokeWidth "0.1"
                    ]
                    [ animateTransform
                        [ attributeType "xml"
                        , attributeName "strokeWidth"
                        , from "0.1"
                        , to "0.3"
                        , dur "5s"
                        , begin "0s"
                        , repeatCount "indefinite"
                        ]
                        []
                    ]
                , Svg.path
                    [ d "M28 66L0 50L0 16L28 0L56 16L56 50L28 66L28 100"
                    , fill "blue"
                    , stroke "red"
                    , strokeWidth "4px"
                    ]
                    []
                ]
            ]
        , rect
            [ fill "url(#hex-background)"
            , width "10"
            , height "10"
            ]
            []
        ]
