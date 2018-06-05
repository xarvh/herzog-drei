module View.Gfx exposing (..)

import ColorPattern exposing (ColorPattern)
import Ease
import Game exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Svg exposing (..)
import View exposing (..)
import View.Mech


deltaAddGfx : Gfx -> Delta
deltaAddGfx c =
    deltaGame <| \game -> { game | cosmetics = c :: game.cosmetics }



--


deltaAddProjectileCase : Vec2 -> Angle -> Delta
deltaAddProjectileCase origin angle =
    deltaAddGfx
        { age = 0
        , maxAge = 0.2
        , render = GfxProjectileCase origin angle
        }


deltaAddBeam : Vec2 -> Vec2 -> ColorPattern -> Delta
deltaAddBeam start end colorPattern =
    deltaAddGfx
        { age = 0
        , maxAge = 2.0
        , render = GfxBeam start end colorPattern
        }


deltaAddRepairBeam : Vec2 -> Vec2 -> Delta
deltaAddRepairBeam start end =
    deltaAddGfx
        { age = 0
        , maxAge = 0.04
        , render = GfxRepairBeam start end
        }


deltaAddExplosion : Vec2 -> Float -> Delta
deltaAddExplosion position size =
    deltaAddGfx
        { age = 0
        , maxAge = 1.0
        , render = GfxExplosion position size
        }


deltaAddFlyingHead : Vec2 -> Vec2 -> ColorPattern -> Delta
deltaAddFlyingHead origin destination colorPattern =
    let
        speed =
            13

        maxAge =
            Vec2.distance origin destination / speed
    in
    deltaAddGfx
        { age = 0
        , maxAge = maxAge
        , render = GfxFlyingHead origin destination colorPattern
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


renderRepairBeam : Vec2 -> Vec2 -> Float -> Svg a
renderRepairBeam start end t =
    let
        dp =
            Vec2.sub end start

        a =
            vecToAngle dp

        l =
            Vec2.length dp

        x1 =
            sin (13 * t)

        x2 =
            cos (50 * t)
    in
    path
        [ transform [ translate start, rotateRad a, scale2 1 l ]
        , d <| "M0,0 C" ++ toString x1 ++ ",0.33 " ++ toString x2 ++ ",0.66 0,1"
        , fill "none"
        , stroke "#2f0"
        , strokeWidth 0.06
        , opacity 0.8
        ]
        []


render : Gfx -> Svg a
render cosmetic =
    let
        t =
            cosmetic.age / cosmetic.maxAge
    in
    case cosmetic.render of
        GfxRepairBeam start end ->
            renderRepairBeam start end t

        GfxProjectileCase origin angle ->
            rect
                [ transform
                    [ translate origin
                    , rotateRad angle
                    , translate2 t 0
                    ]
                , fill "yellow"
                , stroke "#990"
                , strokeWidth 0.02
                , width 0.1
                , height 0.15
                ]
                []

        GfxBeam start end colorPattern ->
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

        GfxExplosion position size ->
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

        GfxFlyingHead origin destination colorPattern ->
            let
                headPosition =
                    Vec2.add (Vec2.scale t destination) (Vec2.scale (1 - t) origin)

                angle =
                    vecToAngle (Vec2.sub destination origin)
            in
            g
                []
                [ renderRepairBeam destination headPosition t
                , g
                    [ transform [ translate headPosition ]
                    , opacity (1 - t * t)
                    ]
                    [ View.Mech.head 0 colorPattern.dark colorPattern.bright angle
                    , View.Mech.headOverlay (0.3 + 0.3 * sin (cosmetic.age * 30)) angle
                    ]
                ]
