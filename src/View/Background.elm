module View.Background exposing (..)

import Game exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Random exposing (Generator)
import Random.Extra
import Svg exposing (Svg)
import Svg.Attributes
import View exposing (..)


type alias Rect =
    { x : Float
    , y : Float
    , w : Float
    , h : Float
    , color : String
    , class : String
    }



-- Random generation


intToRgb : Int -> String
intToRgb n =
    "rgb(" ++ String.fromInt n ++ "," ++ String.fromInt n ++ "," ++ String.fromInt n ++ ")"


sizeGenerator : Generator Float
sizeGenerator =
    Random.float 0.5 3


classGenerator : Generator String
classGenerator =
    let
        floatToClass n =
            if n < 0.03 then
                "background-path"
            else
                ""
    in
    Random.float 0 1 |> Random.map floatToClass


rectGenerator : Int -> Int -> Generator Rect
rectGenerator x y =
    let
        s =
            1

        makeRect xx yy ( w, h ) color class =
            { x = xx
            , y = yy
            , w = w
            , h = h
            , color = color
            , class = class
            }
    in
    Random.map5 makeRect
        (Random.float -s s |> Random.map (\d -> d + toFloat x))
        (Random.float -s s |> Random.map (\d -> d + toFloat y))
        (Random.map2 Tuple.pair sizeGenerator sizeGenerator)
        (Random.int 210 250 |> Random.map intToRgb)
        classGenerator


initRects : Random.Seed -> { a | halfWidth : Int, halfHeight : Int } -> List Rect
initRects seed { halfWidth, halfHeight } =
    let
        generators =
            List.range -halfWidth halfWidth
                |> List.map
                    (\x ->
                        List.range -halfHeight halfHeight
                            |> List.map
                                (\y ->
                                    rectGenerator x y
                                )
                    )

        generator =
            generators
                |> List.concat
                |> Random.Extra.combine
    in
    Random.step generator seed
        |> Tuple.first



-- draw


drawRect : Rect -> Svg a
drawRect rect =
    Svg.rect
        [ x rect.x
        , y rect.y
        , width rect.w
        , height rect.h
        , fill "none"
        , strokeWidth 0.04
        , stroke rect.color
        , Svg.Attributes.class rect.class
        ]
        []



--


terrain : List Rect -> Svg a
terrain rects =
    rects
        |> List.map drawRect
        |> Svg.g []


xterrain : (Vec2 -> Float -> Bool) -> List Rect -> Svg a
xterrain isWithinViewport rects =
    let
        shouldRender : Rect -> Bool
        shouldRender { x, y, w, h } =
            isWithinViewport (vec2 (x + w / 2) (y + h / 2)) (max w h)
    in
    rects
        --|> List.filter shouldRender
        |> List.map drawRect
        |> Svg.g []
