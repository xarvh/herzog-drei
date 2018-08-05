module View.Gfx exposing (..)

import ColorPattern exposing (ColorPattern)
import Colors exposing (..)
import Ease
import Game exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Random
import Svgl.Tree exposing (..)
import View.Mech


healingGreen : ColorPattern
healingGreen =
    { bright = "#2d0"
    , dark = "#090"
    , brightV = vec3 (34 / 255) (221 / 255) 0
    , darkV = vec3 0 (153 / 255) 0
    , key = ""
    }


vampireRed : ColorPattern
vampireRed =
    { bright = "#f11"
    , dark = "#c33"
    , brightV = vec3 1 (17 / 255) (17 / 255)
    , darkV = vec3 (204 / 255) (51 / 255) (51 / 255)
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


fractalBeam : Vec2 -> Vec2 -> ColorPattern -> Float -> Node
fractalBeam start end colorPattern t =
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

        p =
            Vec2.add (Vec2.scale t start) (Vec2.scale (1 - t) end)
    in
    Nod
        [ translate p ]
        [ rect
            { defaultParams
                | fill = colorPattern.brightV
                , stroke = colorPattern.darkV
                , rotate = 7 * x1
                , w = 0.3
                , h = 0.3
            }
        ]


straightBeam : Float -> Vec2 -> Vec2 -> ColorPattern -> Node
straightBeam t start end colorPattern =
    let
        difference =
            Vec2.sub end start

        { x, y } =
            Vec2.add start end |> Vec2.scale 0.5 |> Vec2.toRecord

        rotate =
            vecToAngle difference

        height =
            Vec2.length difference

        width =
            0.1 * (1 + 3 * t)
    in
    rect
        { defaultParams
            | fill = colorPattern.brightV
            , strokeWidth = 0
            , x = x
            , y = y
            , rotate = rotate
            , w = width
            , h = height
            , opacity = 1 - Ease.outExpo t
        }



-- Main Render


render : Gfx -> Node
render cosmetic =
    let
        t =
            cosmetic.age / cosmetic.maxAge
    in
    case cosmetic.render of
        GfxFractalBeam start end colorPattern ->
            fractalBeam start end colorPattern t

        GfxProjectileCase origin angle ->
            Nod
                [ translate origin
                , rotateRad angle
                , translate2 t 0
                ]
                [ rect
                    { defaultParams
                        | fill = yellow
                        , stroke = darkYellow
                        , strokeWidth = 0.02
                        , w = 0.1
                        , h = 0.15
                    }
                ]

        GfxBeam start end colorPattern ->
            straightBeam t start end colorPattern

        GfxExplosion position rawSize ->
            let
                particleCount =
                    1.6 * rawSize |> ceiling

                size =
                    0.3 * rawSize

                particleDiameter =
                    2 * size * (t * 0.9 + 0.1)

                particleByIndex index =
                    let
                        a =
                            turns (toFloat index / toFloat particleCount)

                        x =
                            t * size * cos a

                        y =
                            t * size * sin a
                    in
                    ellipse
                        { defaultParams
                            | fill = yellow
                            , stroke = orange
                            , x = x
                            , y = y
                            , w = particleDiameter
                            , h = particleDiameter
                            , opacity = 1 - t
                        }
            in
            List.range 0 (particleCount - 1)
                |> List.map particleByIndex
                |> Nod [ translate position ]

        GfxFlyingHead class origin destination colorPattern ->
            Nod [] []

        {-
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
        -}
        GfxRepairBubble position ->
            let
                params =
                    { defaultParams
                        | fill = healingGreen.brightV
                        , stroke = healingGreen.brightV
                        , strokeWidth = 0
                        , opacity = 1 - t * t
                    }

                short =
                    0.1

                long =
                    3 * short
            in
            Nod
                [ translate position
                , translate2 0 t
                ]
                [ rect
                    { params
                        | w = short
                        , h = long
                    }
                , rect
                    { params
                        | w = short
                        , h = short
                        , x = short
                    }
                , rect
                    { params
                        | w = short
                        , h = short
                        , x = -short
                    }
                ]

        GfxTrail position angle stretch ->
            ellipse
                { defaultParams
                    | fill = smokeFill
                    , x = Vec2.getX position
                    , y = Vec2.getY position
                    , rotate = angle
                    , w = 0.1 + t * 0.2
                    , h = (1.5 - t) * stretch
                    , opacity = 0.05 * (1 - t * t)
                }
