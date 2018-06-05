module View exposing (..)

import Ease
import Game exposing (Angle, Seconds)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Svg exposing (Svg)
import Svg.Attributes


--


textNotSelectable : Svg.Attribute a
textNotSelectable =
    Svg.Attributes.style "user-select: none; -moz-user-select: none;"


smooth : Float -> Float -> Float -> Float
smooth t a b =
    let
        tt =
            Ease.inOutCubic t
    in
    tt * b + (1 - tt) * a


step : Float -> Float -> Float -> Float
step t a b =
    if t > 0 then
        b
    else
        a



-- String


vecToString : Vec2 -> String
vecToString v =
    let
        ( x, y ) =
            Vec2.toTuple v
    in
    toString x ++ "," ++ toString y



-- Colliders


renderCollider : List Vec2 -> Svg a
renderCollider collider =
    Svg.path
        [ collider
            |> List.map vecToString
            |> String.join " L"
            |> (\s -> "M" ++ s ++ " Z")
            |> d
        , opacity 0.5
        ]
        []



-- Transform attribute


transform : List String -> Svg.Attribute a
transform trs =
    String.join " " trs |> Svg.Attributes.transform


translate : Vec2 -> String
translate v =
    "translate(" ++ vecToString v ++ ")"


translate2 : Float -> Float -> String
translate2 x y =
    "translate(" ++ toString x ++ "," ++ toString y ++ ")"


scale : Float -> String
scale s =
    "scale(" ++ toString s ++ ")"


scale2 : Float -> Float -> String
scale2 x y =
    "scale(" ++ toString x ++ "," ++ toString y ++ ")"


rotateRad : Angle -> String
rotateRad angle =
    rotateDeg <| angle * (180 / pi)


rotateDeg : Angle -> String
rotateDeg angleInDeg =
    "rotate(" ++ toString -angleInDeg ++ ")"



-- Color Attributes


fill =
    Svg.Attributes.fill


stroke =
    Svg.Attributes.stroke


strokeWidth : Float -> Svg.Attribute a
strokeWidth =
    toString >> Svg.Attributes.strokeWidth


opacity : Float -> Svg.Attribute a
opacity =
    toString >> Svg.Attributes.opacity



-- Geometry Attributes


d =
    Svg.Attributes.d


x : Float -> Svg.Attribute a
x =
    toString >> Svg.Attributes.x


y : Float -> Svg.Attribute a
y =
    toString >> Svg.Attributes.y


x1 : Float -> Svg.Attribute a
x1 =
    toString >> Svg.Attributes.x1


y1 : Float -> Svg.Attribute a
y1 =
    toString >> Svg.Attributes.y1


x2 : Float -> Svg.Attribute a
x2 =
    toString >> Svg.Attributes.x2


y2 : Float -> Svg.Attribute a
y2 =
    toString >> Svg.Attributes.y2


r : Float -> Svg.Attribute a
r =
    toString >> Svg.Attributes.r


rx : Float -> Svg.Attribute a
rx =
    toString >> Svg.Attributes.rx


ry : Float -> Svg.Attribute a
ry =
    toString >> Svg.Attributes.ry


cx : Float -> Svg.Attribute a
cx =
    toString >> Svg.Attributes.cx


cy : Float -> Svg.Attribute a
cy =
    toString >> Svg.Attributes.cy


width : Float -> Svg.Attribute a
width =
    toString >> Svg.Attributes.width


height : Float -> Svg.Attribute a
height =
    toString >> Svg.Attributes.height
