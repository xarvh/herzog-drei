module Colors exposing (..)

import Math.Vector3 as Vec3 exposing (Vec3, vec3)


gunFill =
    grey 0.5


gunStroke =
    grey 0.4


smokeFill =
    grey 0.4



--


dark =
    0.6


grey g =
    vec3 g g g



--


white =
    grey 1


red =
    vec3 1 0 0


darkRed =
    vec3 dark 0 0


green =
    vec3 0 1 0


blue =
    vec3 0 0 1


yellow =
    vec3 1 1 0


darkYellow =
    vec3 dark dark 0


orange =
    vec3 1 0.65 0
