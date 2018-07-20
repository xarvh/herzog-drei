module Colors exposing (..)

import Math.Vector3 as Vec3 exposing (Vec3, vec3)


gray g =
    vec3 g g g


gunFill =
    gray 0.5


gunStroke =
    gray (102 / 255)


red =
    vec3 1 0 0


darkRed =
    vec3 (153 / 255) 0 0
