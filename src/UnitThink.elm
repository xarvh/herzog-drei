module UnitThink exposing (..)

import Base
import Game exposing (..)
import SubThink
import View.Gfx
import View.Sub


-- Think


think : Float -> Game -> Unit -> Delta
think dt game unit =
    if unit.integrity <= 0 then
        DeltaList
            [ DeltaList
                [ DeltaGame (Game.removeUnit unit.id)
                , View.Gfx.deltaAddExplosion unit.position 1.0
                ]
            , case unit.component of
                UnitSub sub ->
                    SubThink.destroy game unit sub

                UnitMech mech ->
                    respawnMech game unit.ownerId
            ]
    else
        DeltaList
            [ thinkReload dt game unit
            , case unit.component of
                UnitSub sub ->
                    SubThink.think dt game unit sub

                UnitMech mech ->
                    DeltaNone
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
        DeltaNone



-- Respawn


respawnMech : Game -> Id -> Delta
respawnMech game playerId =
    case Base.playerMainBase game playerId of
        Nothing ->
            DeltaNone

        Just mainBase ->
            DeltaBase mainBase.id (Base.updateOccupied <| \o -> { o | buildCompletion = 0, buildTarget = BuildMech })
