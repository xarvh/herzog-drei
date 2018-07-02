module View.Background exposing (..)

import Game exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Random exposing (Generator)
import Random.Extra
import Svg as S
import Svg.Attributes as SA
import View exposing (..)


-- trash


type alias Rect =
    { x : Float
    , y : Float
    , w : Float
    , h : Float
    , color : String
    , class : String
    }


initRects : Random.Seed -> { a | halfWidth : Int, halfHeight : Int } -> List Rect
initRects seed { halfWidth, halfHeight } =
    [ { x = -halfWidth |> toFloat
      , y = -halfHeight |> toFloat
      , w = halfWidth * 2 |> toFloat
      , h = halfHeight * 2 |> toFloat
      , color = ""
      , class = ""
      }
    ]



--


viewRect rect =
    S.rect
        [ fill "url(#hex-background)"
        , x rect.x
        , y rect.y
        , width rect.w
        , height rect.h
        ]
        []


terrain : List Rect -> S.Svg a
terrain rects =
    let
        ( fill, stroke, strokeWidth ) =
            ( "#fff", "#eee", "3px" )
    in
    S.g
        []
        [ S.defs
            []
            [ S.pattern
                [ SA.id "hex-background"
                , SA.width "56px"
                , SA.height "100px"
                , SA.patternUnits "userSpaceOnUse"
                , SA.patternTransform "scale(0.02)"
                ]
                [ S.rect
                    [ SA.width "100%"
                    , SA.height "100%"
                    , SA.fill fill
                    ]
                    []
                , S.path
                    [ SA.d "M28 66L0 50L0 16L28 0L56 16L56 50L28 66L28 100"
                    , SA.fill fill
                    , SA.stroke stroke
                    , SA.strokeWidth strokeWidth
                    ]
                    []
                ]
            ]
        , rects
            |> List.map viewRect
            |> S.g []
        ]
