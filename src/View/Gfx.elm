module View.Gfx exposing (..)

import ColorPattern exposing (ColorPattern)
import Ease
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Svg exposing (..)
import Svg.Attributes exposing (..)


type alias Seconds =
    Float


type GfxRender
    = Beam Vec2 Vec2 ColorPattern
    | Explosion Vec2 Float


type alias Gfx =
    { age : Seconds
    , maxAge : Seconds
    , render : GfxRender
    }


beam : (Gfx -> a) -> Vec2 -> Vec2 -> ColorPattern -> a
beam toDelta start end colorPattern =
    toDelta
        { age = 0
        , maxAge = 2.0
        , render = Beam start end colorPattern
        }


explosion : (Gfx -> a) -> Vec2 -> Float -> a
explosion toDelta position size =
    toDelta
        { age = 0
        , maxAge = 5.0
        , render = Explosion position size
        }



-- Update


update : Seconds -> Gfx -> Maybe Gfx
update dt cosmetic =
    let
        age =
            cosmetic.age + dt
    in
    if age > cosmetic.maxAge then
        Nothing
    else
        Just { cosmetic | age = age }



-- View


styles =
    String.join ";" >> Svg.Attributes.style


render : Gfx -> Svg a
render cosmetic =
    let
        t =
            cosmetic.age / cosmetic.maxAge
    in
    case cosmetic.render of
        Beam start end colorPattern ->
            line
                [ start |> Vec2.getX |> toString |> x1
                , start |> Vec2.getY |> toString |> y1
                , end |> Vec2.getX |> toString |> x2
                , end |> Vec2.getY |> toString |> y2
                , styles
                    [ "stroke-width:" ++ toString (0.1 * (1 + 3 * t))
                    , "stroke:" ++ colorPattern.bright
                    , "opacity:" ++ toString (1 - Ease.outExpo t)
                    ]
                ]
                []

        Explosion position size ->
            let
                particleCount =
                    5

                particleByIndex index =
                    let
                        a =
                            turns (toFloat index / particleCount)

                        x =
                            t * size * cos a

                        y =
                            t * size * sin a
                    in
                    circle
                        [ cx <| toString x
                        , cy <| toString y
                        , r <| toString <| (t * 0.9 + 0.1) * 0.2 * size
                        , opacity <| toString <| (1 - t) / 3
                        , fill "yellow"
                        , stroke "orange"
                        , strokeWidth "0.1"
                        ]
                        []
            in
            List.range 0 (particleCount - 1)
                |> List.map particleByIndex
                |> g [] --[ transform <| "translate(" ++ Game.vecToString position ++ ")" ]
