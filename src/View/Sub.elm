module View.Sub exposing (..)

import Colors
import Game exposing (Angle, normalizeAngle)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Stats
import Svgl.Tree exposing (..)


-- Physics


collider : Angle -> Vec2 -> List Vec2
collider topAngle position =
    [ vec2 -0.5 0.4
    , vec2 0.5 0.4
    , vec2 0.5 -0.4
    , vec2 -0.5 -0.4
    ]
        |> List.map (Game.rotateVector topAngle)
        |> List.map (Vec2.add position)


gunOffset : Float -> Vec2
gunOffset torsoAngle =
    vec2 0.3 0 |> Game.rotateVector torsoAngle



-- Render


type alias Args =
    { lookAngle : Angle
    , moveAngle : Angle
    , fireAngle : Angle
    , bright : Vec3
    , dark : Vec3
    , isBig : Bool
    }


sub : Args -> Node
sub { lookAngle, moveAngle, fireAngle, bright, dark, isBig } =
    let
        ( fillColor, strokeColor ) =
            if isBig then
                ( dark, bright )
            else
                ( bright, dark )

        gunOrigin =
            gunOffset moveAngle

        height =
            Stats.maxHeight.sub

        params =
            { defaultParams
                | fill = fillColor
                , stroke = strokeColor
            }

        eyeParams =
            { defaultParams
                | fill = Colors.red
                , stroke = Colors.darkRed
                , strokeWidth = 0.02
            }
    in
    Nod []
        [ Nod
            -- gun
            [ translateVz gunOrigin 0, rotateRad fireAngle ]
            [ rect
                { defaultParams
                    | fill = Colors.gunFill
                    , stroke = Colors.gunStroke
                    , y = 0.21
                    , z = 0.5 * height
                    , w = 0.21
                    , h = 1.1
                }
            ]
        , Nod
            -- torso
            [ rotateRad moveAngle ]
            [ rect
                { params
                    | z = 0.7 * height
                    , w = 0.9
                    , h = 0.4
                }
            ]
        , Nod
            [ rotateRad lookAngle ]
            -- head
            [ ellipse
                { params
                    | z = 0.9 * height
                    , w = 0.5
                    , h = 0.6
                }

            -- eye(s)
            , if not isBig then
                ellipse
                    { eyeParams
                        | y = 0.135
                        , w = 0.25
                        , h = 0.3
                    }
              else
                Nod
                    []
                    [ ellipse
                        { eyeParams
                            | x = -0.08
                            , y = 0.1
                            , rotate = degrees 30
                            , w = 0.1
                            , h = 0.2
                        }
                    , ellipse
                        { eyeParams
                            | x = 0.1
                            , y = 0.13
                            , rotate = degrees -20
                            , w = 0.09
                            , h = 0.16
                        }
                    , ellipse
                        { eyeParams
                            | x = 0.1
                            , y = -0.05
                            , rotate = degrees -20
                            , w = 0.09
                            , h = 0.16
                        }
                    ]
            ]
        ]
