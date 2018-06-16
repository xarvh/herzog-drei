module GameTest exposing (..)

import Expect
import Fuzz
import Game
import Test exposing (..)


normalizedAngleFuzzer =
    Fuzz.floatRange -pi (pi - 0.000001)


suite : Test
suite =
    describe "Game"
        [ describe "normalizeAngle"
            [ test "should preserve NaN" <|
                \_ ->
                    let
                        nan =
                            1 / 0 - 1 / 0
                    in
                    Game.normalizeAngle nan
                        |> isNaN
                        |> Expect.true "Should pass NaN"
            , Test.fuzz normalizedAngleFuzzer "should preserve values in [-pi, +pi)" <|
                \float ->
                    Game.normalizeAngle float
                        |> Expect.equal float
            , Test.fuzz (Fuzz.map2 (,) normalizedAngleFuzzer (Fuzz.intRange -3 3)) "should normalize an angle" <|
                \( normalizedAngle, n ) ->
                    Game.normalizeAngle (normalizedAngle + turns (toFloat n))
                        - normalizedAngle
                        |> abs
                        |> Expect.lessThan 1.0e-5
            ]
        ]
