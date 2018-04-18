module UnitThink exposing (..)

import Game
    exposing
        ( Delta(..)
        , Game
        , Id
        , Unit
        , UnitComponent(..)
        )
import SubThink
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
            , case unit.component of
                UnitSub sub ->
                    SubThink.destroy game unit sub

                UnitMech mech ->
                   DeltaList []
            ]
    else
        DeltaList
            [ thinkReload dt game unit
            , case unit.component of
                UnitSub sub ->
                    SubThink.think dt game unit sub

                UnitMech mech ->
                    DeltaList []
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
