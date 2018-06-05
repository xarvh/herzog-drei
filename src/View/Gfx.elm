module View.Gfx exposing (..)

import ColorPattern exposing (ColorPattern)
import Ease
import Game exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Random
import Svg exposing (..)
import View exposing (..)
import View.Mech


addGfx : Gfx -> Game -> Game
addGfx gfx game =
    { game | cosmetics = gfx :: game.cosmetics }


deltaAddGfx : Gfx -> Delta
deltaAddGfx gfx =
    deltaGame (addGfx gfx)


{-| TODO update to Elm 0.19 and replace this with Random.constant
-}
randomConstant : a -> Random.Generator a
randomConstant value =
    Random.bool |> Random.map (always value)


randomlyUpdateGame : Float -> Random.Generator a -> (a -> Game -> Game) -> Game -> Game
randomlyUpdateGame probability generator update game =
    let
        floatToMaybeValue : Float -> Random.Generator (Maybe a)
        floatToMaybeValue float =
            if float > probability then
                randomConstant Nothing
            else
                Random.map Just generator

        ( maybeValue, seed ) =
            Random.step (Random.float 0 1 |> Random.andThen floatToMaybeValue) game.seed

        updateGame =
            case maybeValue of
                Nothing ->
                    identity

                Just value ->
                    update value
    in
    updateGame { game | seed = seed }



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


deltaAddRepairBubbles : Float -> Seconds -> Vec2 -> Delta
deltaAddRepairBubbles bubblesPerSecond dt position =
    let
        addBubble : Float -> Game -> Game
        addBubble randomDx =
            addGfx
                { age = 0
                , maxAge = 1
                , render = GfxRepairBubble (Vec2.add position (vec2 randomDx 0))
                }

        update : Game -> Game
        update =
            randomlyUpdateGame (dt * bubblesPerSecond) (Random.float -0.5 0.5) addBubble
    in
    deltaGame update



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


repairBeam : Vec2 -> Vec2 -> Float -> Svg a
repairBeam start end t =
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
        GfxRepairBeam start end ->
            repairBeam start end t

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
                [ repairBeam destination headPosition t
                , g
                    [ transform [ translate headPosition ]
                    , opacity (1 - t * t)
                    ]
                    [ View.Mech.head 0 colorPattern.dark colorPattern.bright angle
                    , View.Mech.headOverlay (0.3 + 0.3 * sin (cosmetic.age * 30)) angle
                    ]
                ]

        GfxRepairBubble position ->
            cross
                [ opacity (1 - t * t)
                , transform
                    [ translate position
                    , translate2 0 t
                    , scale 0.05
                    ]
                , fill "#2d0"
                , stroke "#090"
                , strokeWidth 0.5
                ]
