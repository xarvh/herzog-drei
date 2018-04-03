module View.Gfx exposing (..)

import ColorPattern exposing (ColorPattern)
import Ease
import Game exposing (Delta(DeltaGame), Gfx, GfxRender(..), Seconds)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Svg exposing (..)
import View exposing (..)


deltaAddGfx : Gfx -> Delta
deltaAddGfx c =
    DeltaGame <| \game -> { game | cosmetics = c :: game.cosmetics }



--


deltaAddBeam : Vec2 -> Vec2 -> ColorPattern -> Delta
deltaAddBeam start end colorPattern =
    deltaAddGfx
        { age = 0
        , maxAge = 2.0
        , render = Beam start end colorPattern
        }


deltaAddExplosion : Vec2 -> Float -> Delta
deltaAddExplosion position size =
    deltaAddGfx
        { age = 0
        , maxAge = 1.0
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


render : Gfx -> Svg a
render cosmetic =
    let
        t =
            cosmetic.age / cosmetic.maxAge
    in
    case cosmetic.render of
        Beam start end colorPattern ->
            let
                ( sx, sy ) =
                    Vec2.toTuple start

                ( ex, ey ) =
                    Vec2.toTuple end
            in
            line
                [ x1 sx
                , y1 sy
                , x2 ex
                , y2 ey
                , strokeWidth (0.1 * (1 + 3 * t))
                , stroke colorPattern.bright
                , opacity (1 - Ease.outExpo t)
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
                        [ cx x
                        , cy y
                        , r <| size * (t * 0.9 + 0.1)
                        , opacity (1 - t)
                        , fill "yellow"
                        , stroke "orange"
                        , strokeWidth 0.1
                        ]
                        []
            in
            List.range 0 (particleCount - 1)
                |> List.map particleByIndex
                |> g
                    [ transform
                        [ translate position
                        , "scale(0.3,0.3)"
                        ]
                    ]
