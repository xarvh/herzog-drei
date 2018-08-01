module View.Base exposing (..)

import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Stats
import Svgl.Tree exposing (..)
import View


teeth : Float -> Float -> Params -> Node
teeth completion radius params =
    let
        n =
            30

        amplitude =
            2 * pi / n

        phase =
            2 * pi * completion

        shiftAngle angle =
            angle + amplitude * sin (angle + phase)

        indexToAngle index =
            toFloat index / toFloat n |> turns

        angleToDot angle =
            Nod
                [ rotateRad angle
                , translate2 radius 0
                , rotateDeg -90
                ]
                [ rect
                    { params
                        | w = 0.15 * radius
                        , h = 0.1 * (1.1 + sin (1.7 * angle + phase)) * radius
                        , strokeWidth = params.strokeWidth * radius
                    }
                ]

        dots =
            List.range 0 (n - 1)
                |> List.map (indexToAngle >> shiftAngle >> angleToDot)
    in
    Nod [] dots


small : Float -> Vec3 -> Vec3 -> Node
small completion bright dark =
    let
        height =
            Stats.maxHeight.base

        params =
            { defaultParams
                | fill = bright
                , stroke = dark
            }

        re { x, y, z, w, h } =
            rect
                { params
                    | x = x
                    , y = y
                    , z = z * height
                    , w = w
                    , h = h
                }

        cir { x, y, z, r } =
            ellipse
                { params
                    | x = x
                    , y = y
                    , z = z * height
                    , w = r * 2
                    , h = r * 2
                }
    in
    Nod []
        [ cir
            { x = 0
            , y = 0
            , z = 0.94
            , r = 1
            }
        , ellipse
            { params
                | z = 0.95
                , w = 1.2 * completion
                , h = 1.2 * completion
                , fill = dark
                , opacity = 0.7
            }
        , teeth completion 0.7 { params | z = 0.955 * height }
        , re
            { x = -1
            , y = 0
            , z = 0.96
            , w = 0.2
            , h = 0.4
            }
        , re
            { x = 1
            , y = 0.15
            , z = 0.96
            , w = 0.2
            , h = 0.15
            }
        , re
            { x = 1
            , y = -0.15
            , z = 0.96
            , w = 0.2
            , h = 0.15
            }
        , cir
            { x = 0.8
            , y = 0.8
            , z = 0.97
            , r = 0.4
            }
        , cir
            { x = -0.8
            , y = 0.8
            , z = 0.97
            , r = 0.4
            }
        , cir
            { x = -0.8
            , y = -0.8
            , z = 0.97
            , r = 0.4
            }
        , cir
            { x = 0.8
            , y = -0.8
            , z = 0.97
            , r = 0.4
            }
        ]


main_ : Float -> Vec3 -> Vec3 -> Node
main_ completion bright dark =
    let
        height =
            Stats.maxHeight.base

        params =
            { defaultParams | fill = bright, stroke = dark }

        re { x, y, z, w, h } =
            rect
                { params
                    | x = x
                    , y = y
                    , z = z * height
                    , w = w
                    , h = h
                }

        tri { x, y, z } =
            {-
               path
                   [ transform [ translate2 xx yy ]
                   , fill bright
                   , stroke dark
                   , strokeWidth 0.03
                   , d "M0 0 L-0.4 -0.1 L-0.4 0.1 Z"
                   ]
                   []
            -}
            ellipse
                { params
                    | x = x
                    , y = y
                    , z = z * height
                    , w = 0.4
                    , h = 0.1
                }

        cir { x, y, z, r } =
            ellipse
                { params
                    | x = x
                    , y = y
                    , z = z * height
                    , w = r * 2
                    , h = r * 2
                }

        cirtri { z, a } =
            cir
                { x = 1.6 * cos (degrees a)
                , y = 1.6 * sin (degrees a)
                , z = z
                , r = 0.15
                }

        slowSin =
            sin (2 * pi * completion)

        fastSin =
            sin (4 * pi * (completion + 0.25))
    in
    Nod []
        -- Main blocks
        [ re
            { x = -1
            , y = -1
            , z = 0.92
            , w = 1.8
            , h = 1.8
            }
        , re
            { x = 1
            , y = -1
            , z = 0.92
            , w = 1.8
            , h = 1.8
            }
        , re
            { x = 1
            , y = 1
            , z = 0.92
            , w = 1.8
            , h = 1.8
            }
        , re
            { x = -1
            , y = 1
            , z = 0.92
            , w = 1.8
            , h = 1.8
            }

        -- bottom horizontal deco
        , re
            { x = 0
            , y = -1.8
            , z = 0.925
            , w = 1
            , h = 0.4
            }

        -- moving vertical bar
        , re
            { x = -1.2 + 0.2 * slowSin
            , y = 0
            , z = 0.925
            , w = 0.2
            , h = 3
            }

        --
        , tri { x = -1.9, y = -0.5, z = 0.93 }
        , tri { x = -1.9, y = -0.8, z = 0.93 }
        , tri { x = -1.9, y = -1.1, z = 0.93 }

        --
        , tri { x = -1.9, y = 0.5, z = 0.93 }
        , tri { x = -1.9, y = 0.8, z = 0.93 }
        , tri { x = -1.9, y = 1.1, z = 0.93 }

        --
        , re
            { x = 0.4
            , y = 1.4 + 0.1 * slowSin
            , z = 0.93
            , w = 0.2
            , h = 0.5
            }
        , re
            { x = 0.7
            , y = 1.4
            , z = 0.93
            , w = 0.2
            , h = 0.5
            }
        , re
            { x = 1.0
            , y = 1.4 + 0.1 * fastSin
            , z = 0.93
            , w = 0.2
            , h = 0.5
            }

        -- central static circle
        , cir
            { x = 0
            , y = 0
            , z = 0.94
            , r = 0.5
            }

        -- orthogonal central circles
        , Nod
            [ rotateRad (pi * (slowSin - fastSin)) ]
            [ re
                { x = -0.5
                , y = 0
                , z = 0.951
                , w = 0.3
                , h = 0.3
                }
            , re
                { x = 0
                , y = -0.5
                , z = 0.952
                , w = 0.3
                , h = 0.3
                }
            , re
                { x = 0.5
                , y = 0
                , z = 0.953
                , w = 0.3
                , h = 0.3
                }
            , re
                { x = 0
                , y = 0.5
                , z = 0.954
                , w = 0.3
                , h = 0.3
                }
            ]

        --
        , cir
            { x = 0.5 * fastSin
            , y = 0.5 * slowSin
            , z = 0.96
            , r = 0.1
            }
        , cir
            { x = 0.5 * slowSin
            , y = 0.5 * -fastSin
            , z = 0.96
            , r = 0.1
            }
        , cir
            { x = 0.5 * -slowSin
            , y = 0.5 * -slowSin
            , z = 0.96
            , r = 0.1
            }
        , cir
            { x = 0.5 * -slowSin
            , y = 0.5 * fastSin
            , z = 0.96
            , r = 0.1
            }

        -- TODO animated completion
        {-
           , circle
               [ fill dark
               , r (0.5 * max 0 (completion - 0.3))
               , opacity 0.7
               ]
               []
           , circle
               [ fill dark
               , r (1.1 * completion)
               , opacity (0.4 + completion / 2)
               ]
               []
        -}
        , ellipse
            { params
                | fill = dark
                , stroke = dark
                , z = 0.97 * height
                , w = 2.2 * completion
                , h = 2.2 * completion
                , opacity = 0.7
            }
        , teeth completion 1.1 { params | z = 0.98 * height }

        --
        , cir
            { x = 1.8
            , y = 1.8
            , z = 0.99
            , r = 0.4
            }
        , cir
            { x = -1.8
            , y = 1.8
            , z = 0.99
            , r = 0.4
            }
        , cir
            { x = -1.8
            , y = -1.8
            , z = 0.99
            , r = 0.4
            }
        , cir
            { x = 1.8
            , y = -1.8
            , z = 0.99
            , r = 0.4
            }

        --
        , cirtri
            { a = -20
            , z = 0.99
            }
        , cirtri
            { a = -40 + 5 * fastSin
            , z = 0.98
            }
        , cirtri
            { a = -60
            , z = 0.99
            }
        ]
