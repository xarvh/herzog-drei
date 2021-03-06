module UnitThink exposing (..)

import Base
import Dict exposing (Dict)
import Game exposing (..)
import MechThink
import SubThink
import View.Gfx
import View.Sub


-- Think


think : Float -> Dict String ( InputState, InputState ) -> Game -> Unit -> Delta
think dt pairedInputStates game unit =
    if unit.integrity <= 0 then
        deltaList
            [ deltaGame (Game.removeUnit unit.id)
            , View.Gfx.deltaAddExplosion unit.position 1.0
            , case unit.component of
                UnitSub sub ->
                    deltaList
                        [ SubThink.destroy game unit sub
                        , View.Gfx.deltaAddFrags game 10 unit.position unit.maybeTeamId
                        ]

                UnitMech mech ->
                    deltaList
                        [ respawnMech game unit mech
                        , addBigSubsToEnemyTeam unit
                        , View.Gfx.deltaAddFrags game 40 unit.position unit.maybeTeamId
                        , deltaShake 0.06
                        ]
            ]
    else
        case unit.component of
            UnitSub sub ->
                SubThink.think dt game unit sub

            UnitMech mech ->
                let
                    input =
                        Dict.get mech.inputKey pairedInputStates
                            |> Maybe.withDefault ( inputStateNeutral, inputStateNeutral )
                in
                MechThink.mechThink input dt game unit mech



-- Big Subs


addBigSubsToEnemyTeam : Unit -> Delta
addBigSubsToEnemyTeam killedUnit =
    case killedUnit.maybeTeamId of
        Nothing ->
            deltaNone

        Just killedUnitTeamId ->
            let
                enemyTeam =
                    case killedUnitTeamId of
                        TeamLeft ->
                            TeamRight

                        TeamRight ->
                            TeamLeft
            in
            -- do not allow accumulation beyond 3
            deltaTeam enemyTeam (\g t -> { t | bigSubsToSpawn = 3 })



-- Respawn


respawnMech : Game -> Unit -> MechComponent -> Delta
respawnMech game unit mech =
    case Base.teamMainBase game unit.maybeTeamId of
        Nothing ->
            -- base destroyed, can't respawn
            deltaNone

        Just mainBase ->
            deltaList
                [ View.Gfx.deltaAddFlyingHead mech.class unit.position mainBase.position (teamColorPattern game unit.maybeTeamId)
                , deltaBase mainBase.id (Base.updateOccupied <| \o -> { o | mechBuildCompletions = ( mech, 0 ) :: o.mechBuildCompletions })
                ]
