module ColorPattern exposing (..)

import Math.Vector3 as Vec3 exposing (Vec3, vec3)
import Random
import Random.List


type alias ColorPattern =
    { bright : String
    , dark : String
    , brightV : Vec3
    , darkV : Vec3
    , key : String
    }


vecToRgb : Vec3 -> String
vecToRgb v =
    let
        { x, y, z } =
            Vec3.toRecord v

        f2s f =
            f * 255 |> ceiling |> String.fromInt
    in
    "rgb(" ++ f2s x ++ "," ++ f2s y ++ "," ++ f2s z ++ ")"


pattern : Vec3 -> Vec3 -> String -> ColorPattern
pattern bright dark key =
    { brightV = bright
    , darkV = dark
    , bright = vecToRgb bright
    , dark = vecToRgb dark
    , key = key
    }


patterns : List ColorPattern
patterns =
    let
        n =
            vec3

        b r g bb =
            vec3 (r / 255) (g / 255) (bb / 255)
    in
    [ pattern (n 1 0 0) (n 0.5 0 0) "red"
    , pattern (b 255 165 0) (n 0 0 1) "sol"
    , pattern (n 0 1 0) (n 0 0.5 0) "green"
    , pattern (n 0 0 1) (n 0 0 0.5) "blue"
    , pattern (b 0 238 238) (n 0 0.5 0.5) "cyan"
    , pattern (n 1 0 1) (n 0.5 0 0.5) "purple"
    , pattern (b 238 238 0) (n 0.5 0.5 0) "yellow"
    , pattern (b 0 238 238) (n 0.5 0 0.5) "octarine"
    , pattern (b 50 50 50) (b 224 156 31) "brass"
    ]


neutral : ColorPattern
neutral =
    pattern (vec3 0.73 0.73 0.73) (vec3 0.5 0.5 0.5) "grey"


twoDifferent : Random.Generator ( ColorPattern, ColorPattern )
twoDifferent =
    let
        takeTwo : List ColorPattern -> ( ColorPattern, ColorPattern )
        takeTwo list =
            case list of
                a :: b :: _ ->
                    ( a, b )

                _ ->
                    ( neutral, neutral )
    in
    Random.List.shuffle patterns |> Random.map takeTwo
