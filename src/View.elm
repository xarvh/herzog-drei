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


step : Float -> Float -> Float -> Float -> Float
step t threshold a b =
    if t > threshold then
        b
    else
        a



-- Round Arc


roundArcD : Float -> Float -> Float -> Svg.Attribute a
roundArcD radius startA endA =
    let
        -- https://stackoverflow.com/questions/5736398/how-to-calculate-the-svg-path-for-an-arc-of-a-circle
        startX =
            radius * cos startA |> String.fromFloat

        startY =
            radius * sin startA |> String.fromFloat

        endX =
            radius * cos endA |> String.fromFloat

        endY =
            radius * sin endA |> String.fromFloat

        largeArcFlag =
            if endA - startA <= pi then
                "0"
            else
                "1"

        rr =
            String.fromFloat radius
    in
    [ "M 0 0 L", startX, startY, "A", rr, rr, "0", largeArcFlag, "0", endX, endY ]
        |> String.join " "
        |> d



-- String


vecToString : Vec2 -> String
vecToString vector =
    let
        v =
            Vec2.toRecord vector
    in
    String.fromFloat v.x ++ "," ++ String.fromFloat v.y



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
translate2 xx yy =
    "translate(" ++ String.fromFloat xx ++ "," ++ String.fromFloat yy ++ ")"


scale : Float -> String
scale s =
    "scale(" ++ String.fromFloat s ++ ")"


scale2 : Float -> Float -> String
scale2 xx yy =
    "scale(" ++ String.fromFloat xx ++ "," ++ String.fromFloat yy ++ ")"


rotateRad : Angle -> String
rotateRad angle =
    rotateDeg <| angle * (180 / pi)


rotateDeg : Angle -> String
rotateDeg angleInDeg =
    "rotate(" ++ String.fromFloat -angleInDeg ++ ")"



-- Color Attributes


fill =
    Svg.Attributes.fill


stroke =
    Svg.Attributes.stroke


strokeWidth : Float -> Svg.Attribute a
strokeWidth =
    String.fromFloat >> Svg.Attributes.strokeWidth


opacity : Float -> Svg.Attribute a
opacity =
    String.fromFloat >> Svg.Attributes.opacity



-- Geometry Attributes


d =
    Svg.Attributes.d


x : Float -> Svg.Attribute a
x =
    String.fromFloat >> Svg.Attributes.x


y : Float -> Svg.Attribute a
y =
    String.fromFloat >> Svg.Attributes.y


x1 : Float -> Svg.Attribute a
x1 =
    String.fromFloat >> Svg.Attributes.x1


y1 : Float -> Svg.Attribute a
y1 =
    String.fromFloat >> Svg.Attributes.y1


x2 : Float -> Svg.Attribute a
x2 =
    String.fromFloat >> Svg.Attributes.x2


y2 : Float -> Svg.Attribute a
y2 =
    String.fromFloat >> Svg.Attributes.y2


r : Float -> Svg.Attribute a
r =
    String.fromFloat >> Svg.Attributes.r


rx : Float -> Svg.Attribute a
rx =
    String.fromFloat >> Svg.Attributes.rx


ry : Float -> Svg.Attribute a
ry =
    String.fromFloat >> Svg.Attributes.ry


cx : Float -> Svg.Attribute a
cx =
    String.fromFloat >> Svg.Attributes.cx


cy : Float -> Svg.Attribute a
cy =
    String.fromFloat >> Svg.Attributes.cy


width : Float -> Svg.Attribute a
width =
    String.fromFloat >> Svg.Attributes.width


height : Float -> Svg.Attribute a
height =
    String.fromFloat >> Svg.Attributes.height
