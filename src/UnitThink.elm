module UnitThink exposing (..)

import Game
    exposing
        ( Delta(..)
        , Game
        , Id
        , Unit
        , UnitType(..)
        , UnitTypeMechRecord
        , UnitTypeSubRecord
        )
import UnitTypeMechThink
import UnitTypeSubThink
import View.Gfx
import View.Unit


-- Think


think : Float -> Game -> Unit -> Delta
think dt game unit =
    if unit.hp < 1 then
        DeltaList
            [ DeltaList
                [ DeltaGame (Game.removeUnit unit.id)
                , View.Gfx.deltaAddExplosion unit.position 1.0
                ]
            , case unit.type_ of
                UnitTypeSub subRecord ->
                    UnitTypeSubThink.destroy game unit subRecord

                UnitTypeMech mechRecord ->
                    UnitTypeMechThink.destroy game unit mechRecord
            ]
    else
        DeltaList
            [ thinkReload dt game unit
            , case unit.type_ of
                UnitTypeSub subRecord ->
                    UnitTypeSubThink.think dt game unit subRecord

                UnitTypeMech mechRecord ->
                    UnitTypeMechThink.think dt game unit mechRecord
            ]



-- Reloading


thinkReload : Float -> Game -> Unit -> Delta
thinkReload dt game unit =
    if unit.timeToReload > 0 then
        let
            timeToReload =
                max 0 (unit.timeToReload - dt)
        in
        DeltaUnit unit.id (\g u -> { u | timeToReload = timeToReload })
    else
        DeltaList []
