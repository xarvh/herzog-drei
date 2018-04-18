module Unit exposing (..)

import Game exposing (..)


takeDamage : Int -> Game -> Unit -> Unit
takeDamage rawDamage game unit =
    let
        ( healthPoints, armor ) =
            case unit.component of
                UnitMech _ ->
                    ( 60, 1 )

                UnitSub sub ->
                    case sub.mode of
                        UnitModeFree ->
                            ( 20, 0 )

                        UnitModeBase baseId ->
                            ( 24, 1 )

        damage =
            toFloat (rawDamage - armor) / healthPoints |> max 0
    in
    { unit | integrity = unit.integrity - damage }
