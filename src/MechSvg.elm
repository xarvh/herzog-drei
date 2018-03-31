module MechSvg exposing (..)

import Ease
import Game exposing (normalizeAngle)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Svg exposing (..)
import Svg.Attributes exposing (..)


styles =
    String.join ";" >> Svg.Attributes.style


path =
    Svg.path


a2s : Float -> String
a2s angle =
    angle
        |> Game.radiantsToDegrees
        |> toString



-- Mech
{-
   gunOffset : Float -> Vec2
   gunOffset torsoAngle =
       vec2 0.3 0 |> Game.rotateVector torsoAngle
-}


mech : Float -> String -> String -> Svg a
mech topAngle brightColor darkColor =
    let
        bodyStyle =
            styles
                [ "fill:" ++ darkColor
                , "stroke:" ++ brightColor
                , "stroke-width:0.03"
                ]

        eyesStyle =
            styles
                [ "fill:#f80000"
                , "stroke:#ff8383"
                , "stroke-width:0.00553906"
                ]
    in
    g
        [ transform <| "scale(3,-3) rotate(" ++ a2s topAngle ++ ") translate(0,-287.00002)" ]
        [ rect
            [ y "286.65598"
            , x "-0.34999204"
            , height "0.26498201"
            , width "0.083487481"
            , bodyStyle
            ]
            []
        , rect
            [ transform "scale(-1,1)"
            , bodyStyle
            , width "0.083487481"
            , height "0.26498201"
            , x "-0.35230175"
            , y "286.65598"
            ]
            []
        , rect
            [ y "286.86285"
            , x "-0.42440477"
            , height "0.23229113"
            , width "0.20145902"
            , bodyStyle
            ]
            []
        , rect
            [ y "286.95251"
            , x "-0.29396078"
            , height "0.16940348"
            , width "0.6519469"
            , bodyStyle
            ]
            []
        , rect
            [ transform "scale(-1,1)"
            , bodyStyle
            , width "0.20145902"
            , height "0.23229113"
            , x "-0.42671448"
            , y "286.86285"
            ]
            []
        , rect
            [ bodyStyle
            , width "0.20277083"
            , height "0.23613821"
            , x "-0.38636273"
            , y "286.91919"
            ]
            []
        , rect
            [ y "286.91919"
            , x "0.18590166"
            , height "0.23613821"
            , width "0.20277083"
            , bodyStyle
            ]
            []
        , ellipse
            [ cx "0.010910868"
            , cy "286.99118"
            , rx "0.084701769"
            , ry "0.16940352"
            , bodyStyle
            ]
            []
        , ellipse
            [ transform "rotate(13.994631)"
            , eyesStyle
            , ry "0.027490584"
            , rx "0.017793473"
            , cy "278.37259"
            , cx "69.358574"
            ]
            []
        , ellipse
            [ cx "35.681171"
            , cy "284.72101"
            , rx "0.017793473"
            , ry "0.027490584"
            , eyesStyle
            , transform "rotate(7.151609)"
            ]
            []
        , ellipse
            [ cx "69.338051"
            , cy "278.37772"
            , rx "0.017793473"
            , ry "0.027490584"
            , eyesStyle
            , transform "matrix(-0.97031839,0.24183097,0.24183097,0.97031839,0,0)"
            ]
            []
        , ellipse
            [ transform "matrix(-0.9922202,0.12449527,0.12449527,0.9922202,0,0)"
            , eyesStyle
            , ry "0.027490584"
            , rx "0.017793473"
            , cy "284.72379"
            , cx "35.659008"
            ]
            []
        ]
