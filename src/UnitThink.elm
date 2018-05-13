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
        deltaList
            [ deltaList
                [ deltaGame (Game.removeUnit unit.id)
                , View.Gfx.deltaAddExplosion unit.position 1.0
                ]
            , case unit.component of
                UnitSub sub ->
                    SubThink.destroy game unit sub

                UnitMech mech ->
                    respawnMech game mech.playerKey unit.teamId
            ]
    else
        deltaList
            [ thinkReload dt game unit
            , case unit.component of
                UnitSub sub ->
                    SubThink.think dt game unit sub

                UnitMech mech ->
                    deltaNone
            ]



-- Reloading


thinkReload : Float -> Game -> Unit -> Delta
thinkReload dt game unit =
    if unit.timeToReload > 0 then
        let
            timeToReload =
                max 0 (unit.timeToReload - dt)
        in
        deltaUnit unit.id (\g u -> { u | timeToReload = timeToReload })
    else
        deltaNone



-- Respawn


respawnMech : Game -> String -> Id -> Delta
respawnMech game playerKey teamId =
    case Base.teamMainBase game teamId of
        Nothing ->
            deltaNone

        Just mainBase ->
            deltaBase mainBase.id (Base.updateOccupied <| \o -> { o | mechBuildCompletions = ( playerKey, 0 ) :: o.mechBuildCompletions })
