module Colors exposing (..)

import Math.Vector3 as Vec3 exposing (Vec3, vec3)


gunFill =
    gray 0.5


gunStroke =
    gray 0.4


smokeFill =
    gray 0.4



--


dark =
    0.6


gray g =
    vec3 g g g



--


red =
    vec3 1 0 0


darkRed =
    vec3 dark 0 0


yellow =
    vec3 1 1 0


darkYellow =
    vec3 dark dark 0


orange =
    vec3 1 0.65 0
