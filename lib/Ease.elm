module Ease exposing (Easing, bezier, flip, inBack, inBounce, inCirc, inCubic, inElastic, inExpo, inOut, inOutBack, inOutBounce, inOutCirc, inOutCubic, inOutElastic, inOutExpo, inOutQuad, inOutQuart, inOutQuint, inOutSine, inQuad, inQuart, inQuint, inSine, linear, outBack, outBounce, outCirc, outCubic, outElastic, outExpo, outQuad, outQuart, outQuint, outSine, retour, reverse)

{-| An easing function is used in animation to make a transition between two values appear more lifelike or interesting.
Easing functions can make sliding panels or bouncing menus appear to be physical objects.

All easing functions expect inputs to be bewteen zero and one, and will typically output in that range. Easing "in"
happens at the start of the transition, easing "out" at the end, and "inOut" on both sides. The functions provided here
are meant to match the graphical examples on [easings.net](http://easings.net/).

    import Ease
    n = 10

    List.map (\i -> Ease.inQuad (i/n)) [0..n]
    > [0, 0.01, 0.04, 0.09, 0.16, 0.25, 0.36, 0.49, 0.64, 0.81, 1]

    List.map (\i -> Ease.outCubic (i/n)) [0..n]
    > [0, 0.271, 0.488, 0.657, 0.784, 0.875, 0.936, 0.973, 0.992, 0.999, 1]


# Easing functions

@docs Easing,
bezier,
linear,
inQuad, outQuad, inOutQuad,
inCubic, outCubic, inOutCubic,
inQuart, outQuart, inOutQuart,
inQuint, outQuint, inOutQuint,
inSine, outSine, inOutSine,
inExpo, outExpo, inOutExpo,
inCirc, outCirc, inOutCirc,
inBack, outBack, inOutBack,
inBounce, outBounce, inOutBounce,
inElastic, outElastic, inOutElastic


# Combining easing functions

@docs reverse, flip , inOut, retour

-}


{-| A type alias to make it easier to refer to easing functions.
-}
type alias Easing =
    Float -> Float


{-| A linear ease, equal to the identity function. Linear eases often appear mechanical and unphysical.
-}
linear : Easing
linear =
    identity


{-| A cubic bezier function using 4 parameters: x and y position of first control point, and x and y position of second control point.

See [here](http://greweb.me/glsl-transition/example/ "glsl-transitions") for examples or [here](http://cubic-bezier.com/ "tester") to test.

-}
bezier : Float -> Float -> Float -> Float -> Easing
bezier x1 y1 x2 y2 time =
    let
        lerp from to v =
            from + (to - from) * v

        pair interpolate ( a0, b0 ) ( a1, b1 ) v =
            ( interpolate a0 a1 v, interpolate b0 b1 v )

        casteljau ps =
            case ps of
                [ ( x, y ) ] ->
                    y

                xs ->
                    List.map2 (\x y -> pair lerp x y time) xs (Maybe.withDefault [] (List.tail xs))
                        |> casteljau
    in
    casteljau [ ( 0, 0 ), ( x1, y1 ), ( x2, y2 ), ( 1, 1 ) ]


{-| -}
inQuad : Easing
inQuad time =
    time ^ 2


{-| -}
outQuad : Easing
outQuad =
    flip inQuad


{-| -}
inOutQuad : Easing
inOutQuad =
    inOut inQuad outQuad


{-| -}
inCubic : Easing
inCubic time =
    time ^ 3


{-| -}
outCubic : Easing
outCubic =
    flip inCubic


{-| -}
inOutCubic : Easing
inOutCubic =
    inOut inCubic outCubic


{-| -}
inQuart : Easing
inQuart time =
    time ^ 4


{-| -}
outQuart : Easing
outQuart =
    flip inQuart


{-| -}
inOutQuart : Easing
inOutQuart =
    inOut inQuart outQuart


{-| -}
inQuint : Easing
inQuint time =
    time ^ 5


{-| -}
outQuint : Easing
outQuint =
    flip inQuint


{-| -}
inOutQuint : Easing
inOutQuint =
    inOut inQuint outQuint


{-| -}
inSine : Easing
inSine =
    flip outSine


{-| -}
outSine : Easing
outSine time =
    sin (time * (pi / 2))


{-| -}
inOutSine : Easing
inOutSine =
    inOut inSine outSine


{-| -}
inExpo : Easing
inExpo time =
    if time == 0.0 then
        0.0
        -- exact zero instead of 2^-10
    else
        2 ^ (10 * (time - 1))


{-| -}
outExpo : Easing
outExpo =
    flip inExpo


{-| -}
inOutExpo : Easing
inOutExpo =
    inOut inExpo outExpo


{-| -}
inCirc : Easing
inCirc =
    flip outCirc


{-| -}
outCirc : Easing
outCirc time =
    sqrt (1 - (time - 1) ^ 2)


{-| -}
inOutCirc : Easing
inOutCirc =
    inOut inCirc outCirc


{-| -}
inBack : Easing
inBack time =
    time * time * (2.70158 * time - 1.70158)


{-| -}
outBack : Easing
outBack =
    flip inBack


{-| -}
inOutBack : Easing
inOutBack =
    inOut inBack outBack


{-| -}
inBounce : Easing
inBounce =
    flip outBounce


{-| -}
outBounce : Easing
outBounce time =
    let
        a =
            7.5625

        t2 =
            time - (1.5 / 2.75)

        t3 =
            time - (2.25 / 2.75)

        t4 =
            time - (2.625 / 2.75)
    in
    if time < 1 / 2.75 then
        a * time * time
    else if time < 2 / 2.75 then
        a * t2 * t2 + 0.75
    else if time < 2.5 / 2.75 then
        a * t3 * t3 + 0.9375
    else
        a * t4 * t4 + 0.984375


{-| -}
inOutBounce : Easing
inOutBounce =
    inOut inBounce outBounce


{-| -}
inElastic : Easing
inElastic time =
    if time == 0.0 then
        0.0
    else
        let
            s =
                0.075

            p =
                0.3

            t =
                time - 1
        in
        -((2 ^ (10 * t)) * sin ((t - s) * (2 * pi) / p))


{-| -}
outElastic : Easing
outElastic =
    flip inElastic


{-| -}
inOutElastic : Easing
inOutElastic =
    inOut inElastic outElastic


{-| Makes an easing function using two other easing functions. The first half the first `Easing` function is used, the other half the second.
-}
inOut : Easing -> Easing -> Easing
inOut e1 e2 time =
    if time < 0.5 then
        e1 (time * 2) / 2
    else
        0.5 + e2 ((time - 0.5) * 2) / 2


{-| Flip an easing function. A transition that starts fast and continues slow now starts slow and continues fast.

Graphically, this flips the function around x = 0.5 and then around y = 0.5.

-}
flip : Easing -> Easing
flip easing time =
    1 - easing (1 - time)


{-| Reverse an `Easing` function. If an object follows an easing function and then the reversed easing function, it
retraces exactly the same path, backwards.

Graphically, this flips the function around x = 0.5.

-}
reverse : Easing -> Easing
reverse easing time =
    easing (1 - time)


{-| Makes an `Easing` function go to the end first and then back to the start. A transition that starts low and goes
high now starts low, goes high at halfway, and then goes low again.
-}
retour : Easing -> Easing
retour easing time =
    if time < 0.5 then
        easing (time * 2)
    else
        (time - 0.5)
            * 2
            |> flip easing
