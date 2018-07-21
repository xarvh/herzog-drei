module View.Gfx exposing (..)

import ColorPattern exposing (ColorPattern)
import Ease
import Game exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Random
import Svg exposing (..)
import View exposing (..)
import View.Mech


healingGreen : ColorPattern
healingGreen =
    { bright = "#2d0"
    , dark = "#090"
    , brightV = vec3 0 0 0
    , darkV = vec3 0 0 0
    , key = ""
    }


vampireRed : ColorPattern
vampireRed =
    { bright = "#f11"
    , dark = "#c33"
    , brightV = vec3 0 0 0
    , darkV = vec3 0 0 0
    , key = ""
    }



--


addGfx : Gfx -> Game -> Game
addGfx gfx game =
    { game | cosmetics = gfx :: game.cosmetics }


deltaAddGfx : Gfx -> Delta
deltaAddGfx gfx =
    deltaGame (addGfx gfx)


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
        , render = GfxFractalBeam start end healingGreen
        }


deltaAddVampireBeam : Vec2 -> Vec2 -> Delta
deltaAddVampireBeam start end =
    deltaAddGfx
        { age = 0
        , maxAge = 0.02
        , render = GfxFractalBeam start end vampireRed
        }


deltaAddExplosion : Vec2 -> Float -> Delta
deltaAddExplosion position size =
    deltaAddGfx
        { age = 0
        , maxAge = 1.0
        , render = GfxExplosion position size
        }


deltaAddFlyingHead : MechClass -> Vec2 -> Vec2 -> ColorPattern -> Delta
deltaAddFlyingHead class origin destination colorPattern =
    let
        speed =
            30

        maxAge =
            Vec2.distance origin destination / speed
    in
    deltaAddGfx
        { age = 0
        , maxAge = maxAge
        , render = GfxFlyingHead class origin destination colorPattern
        }


deltaAddRepairBubbles : Float -> Seconds -> Vec2 -> Delta
deltaAddRepairBubbles bubblesPerSecond dt position =
    let
        displacementToGfx : Float -> Gfx
        displacementToGfx randomDx =
            { age = 0
            , maxAge = 1
            , render = GfxRepairBubble (Vec2.add position (vec2 randomDx 0))
            }
    in
    Random.float -0.5 0.5
        |> deltaRandom (displacementToGfx >> deltaAddGfx)
        |> deltaWithChance (dt * bubblesPerSecond)


deltaAddTrail : { position : Vec2, angle : Angle, stretch : Float } -> Delta
deltaAddTrail { position, angle, stretch } =
    deltaAddGfx
        { age = 0
        , maxAge = 1
        , render = GfxTrail position angle stretch
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



-- Item Render


fractalBeam : Vec2 -> Vec2 -> ColorPattern -> Float -> Svg a
fractalBeam start end { bright, dark } t =
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
        , d <| "M0,0 C" ++ String.fromFloat x1 ++ ",0.33 " ++ String.fromFloat x2 ++ ",0.66 0,1"
        , fill "none"
        , stroke bright
        , strokeWidth 0.06
        , opacity 0.8
        ]
        []


cross : List (Svg.Attribute a) -> Svg a
cross attrs =
    let
        p =
            [ "M 1,1"
            , "L 3,1"
            , "L 3,-1"
            , "L 1,-1"
            , "L 1,-3"
            , "L -1,-3"
            , "L -1,-1"
            , "L -3,-1"
            , "L -3,1"
            , "L -1,1"
            , "L -1,3"
            , "L 1,3"
            , "Z"
            ]
                |> String.join " "
                |> d
    in
    path (p :: attrs) []



-- Main Render


render : Gfx -> Svg a
render cosmetic =
    let
        t =
            cosmetic.age / cosmetic.maxAge
    in
    case cosmetic.render of
        GfxFractalBeam start end colorPattern ->
            fractalBeam start end colorPattern t

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
                s =
                    Vec2.toRecord start

                e =
                    Vec2.toRecord end
            in
            line
                [ x1 s.x
                , y1 s.y
                , x2 e.x
                , y2 e.y
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

        GfxFlyingHead class origin destination colorPattern ->
            let
                headPosition =
                    Vec2.add (Vec2.scale t destination) (Vec2.scale (1 - t) origin)

                angle =
                    vecToAngle (Vec2.sub destination origin)
            in
            g
                []
                [ fractalBeam destination headPosition healingGreen t
                , g
                    [ transform [ translate headPosition ]
                    , opacity (1 - t * t)
                    ]
                    []
                    {- TODO
                    [ View.Mech.head class 0 colorPattern.dark colorPattern.bright angle
                    View.Mech.headOverlay (0.3 + 0.3 * sin (cosmetic.age * 30)) angle
                    ]
                    -}
                ]

        GfxRepairBubble position ->
            cross
                [ opacity (1 - t * t)
                , transform
                    [ translate position
                    , translate2 0 t
                    , scale 0.05
                    ]
                , fill healingGreen.bright
                , stroke healingGreen.dark
                , strokeWidth 0.5
                ]

        GfxTrail position angle stretch ->
            ellipse
                [ transform [ translate position, rotateRad angle ]
                , opacity (0.05 * (1 - t * t))

                --
                , rx (0.1 + t * 0.2)
                , ry ((1.5 - t) * stretch)
                , fill "#666"
                ]
                []
