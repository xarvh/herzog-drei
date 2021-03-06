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


addGfx : { duration : Seconds, render : GfxRender } -> Game -> Game
addGfx { duration, render } game =
    let
        gfx =
            { spawnTime = game.time
            , removeTime = game.time + duration
            , render = render
            }
    in
    { game | cosmetics = gfx :: game.cosmetics }


deltaAddGfx : { duration : Seconds, render : GfxRender } -> Delta
deltaAddGfx seed =
    deltaGame (addGfx seed)


deltaAddProjectileCase : Vec2 -> Angle -> Delta
deltaAddProjectileCase origin angle =
    deltaAddGfx
        { duration = 0.2
        , render = GfxProjectileCase origin angle
        }


deltaAddBeam : Vec2 -> Vec2 -> ColorPattern -> Delta
deltaAddBeam start end colorPattern =
    deltaAddGfx
        { duration = 2.0
        , render = GfxBeam start end colorPattern
        }


deltaAddRepairBeam : Vec2 -> Vec2 -> Delta
deltaAddRepairBeam start end =
    deltaAddGfx
        { duration = 0.04
        , render = GfxFractalBeam start end healingGreen
        }


deltaAddVampireBeam : Vec2 -> Vec2 -> Delta
deltaAddVampireBeam start end =
    deltaAddGfx
        { duration = 0.02
        , render = GfxFractalBeam start end vampireRed
        }


deltaAddExplosion : Vec2 -> Float -> Delta
deltaAddExplosion position size =
    let
        angleToDelta a =
            deltaAddGfx
                { duration = 1.0
                , render = GfxExplosion position size a
                }
    in
    deltaRandom angleToDelta (Random.float -pi pi)


deltaAddFlyingHead : MechClass -> Vec2 -> Vec2 -> ColorPattern -> Delta
deltaAddFlyingHead class origin destination colorPattern =
    let
        speed =
            30

        duration =
            Vec2.distance origin destination / speed
    in
    deltaAddGfx
        { duration = duration
        , render = GfxFlyingHead class origin destination colorPattern
        }


deltaAddRepairBubbles : Float -> Seconds -> Vec2 -> Delta
deltaAddRepairBubbles bubblesPerSecond dt position =
    let
        displacementToGfx randomDx =
            { duration = 1
            , render = GfxRepairBubble (Vec2.add position (vec2 randomDx 0))
            }
    in
    Random.float -0.5 0.5
        |> deltaRandom (displacementToGfx >> deltaAddGfx)
        |> deltaWithChance (dt * bubblesPerSecond)


deltaAddTrail : { position : Vec2, angle : Angle, stretch : Float } -> Delta
deltaAddTrail { position, angle, stretch } =
    deltaAddGfx
        { duration = 1
        , render = GfxTrail position angle stretch
        }


deltaAddFrags : Game -> Int -> Vec2 -> Maybe TeamId -> Delta
deltaAddFrags game n origin maybeTeamId =
    let
        colorPattern =
            teamColorPattern game maybeTeamId

        -- TODO move these somewhere out
        generateBool =
            Random.int 0 1 |> Random.map (\i -> i == 0)

        generateInterval =
            Random.float -1 1

        generateVector =
            Random.map2 vec2 generateInterval generateInterval

        generateSize =
            Random.pair (Random.float 0.1 0.5) (Random.float 0.1 0.5)

        generateAngle =
            Random.float -pi pi

        generateDelta =
            Random.map5 makeGfx
                generateSize
                generateVector
                generateAngle
                generateInterval
                generateBool

        makeGfx ( w, h ) v a va isTris =
            deltaAddGfx
                { duration = 2
                , render =
                    GfxFrag
                        { fill = colorPattern.brightV
                        , stroke = colorPattern.darkV
                        , w = w
                        , h = h
                        , origin = origin
                        , angle = a
                        , speed = Vec2.scale 6 v
                        , angularVelocity = 2 * pi * va
                        , isTris = isTris
                        }
                }

        addFrag =
            DeltaRandom generateDelta
    in
    deltaList (List.repeat n addFrag)



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


view : Game -> Gfx -> Node
view game cosmetic =
    let
        t =
            (game.time - cosmetic.spawnTime) / (cosmetic.removeTime - cosmetic.spawnTime)
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

        GfxExplosion position rawSize angle ->
            let
                particleCount =
                    1.6 * rawSize |> ceiling |> min 6

                size =
                    0.3 * rawSize

                particleDiameter =
                    2 * size * (t * 0.9 + 0.1)

                particleByIndex index =
                    let
                        a =
                            angle + turns (toFloat index / toFloat particleCount)

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

        GfxFrag { fill, stroke, w, h, origin, angle, speed, angularVelocity, isTris } ->
            let
                a =
                    angle + t * angularVelocity

                { x, y } =
                    speed
                        |> Vec2.scale t
                        |> Vec2.add origin
                        |> Vec2.toRecord

                prim =
                    if isTris then
                        rightTri
                    else
                        rect
            in
            prim
                { defaultParams
                    | fill = fill
                    , stroke = stroke
                    , w = w
                    , h = h
                    , rotate = a
                    , x = x
                    , y = y
                    , opacity = 1 - t
                }
