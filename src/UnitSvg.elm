module UnitSvg exposing (..)

import Svg exposing (..)
import Svg.Attributes exposing (..)


styles =
    String.join ";" >> Svg.Attributes.style


path =
    Svg.path


unit : Float -> Float -> String -> String -> Svg a
unit move aim brightColor darkColor =
    g
        [ transform "scale(0.5,-0.5)" ]
        [ rect
            [ transform <| "rotate(" ++ toString -aim ++ ")"
            , styles
                [ "fill:#808080"
                , "stroke:" ++ darkColor
                , "stroke-width:0.1"
                ]
            , width "0.42169011"
            , height "2.1875174"
            , x "0.60082167"
            , y "-1.256899999999678"
            ]
            []
        , ellipse
            [ transform <| "rotate(" ++ toString -move ++ ")"
            , ry "0.57400334"
            , rx "0.89938557"
            , cy "-0.05889999999999418"
            , cx "-0.00096507149"
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
            , transform <| "rotate(" ++ toString -aim ++ ") translate(0,-272.13998) matrix(0.11036153,0,0,0.17636706,-1.1985001,222.90086)"
            ]
            []
        , ellipse
            [ transform <| "rotate(" ++ toString -aim ++ ")"
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
