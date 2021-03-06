module BaseThink exposing (..)

import Base
import Dict exposing (Dict)
import Game exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Set exposing (Set)
import Unit
import View.Gfx


maxSubsPerTeam =
    30


subBuildSpeed =
    0.2


mechBuildSpeed =
    0.5



-- Think


unitDoesCountTowardsCap : Unit -> Bool
unitDoesCountTowardsCap unit =
    case unit.component of
        UnitMech _ ->
            False

        UnitSub sub ->
            sub.mode == UnitModeFree


teamHasReachedUnitCap : Game -> TeamId -> Bool
teamHasReachedUnitCap game teamId =
    game.unitById
        |> Dict.filter (\id u -> u.maybeTeamId == Just teamId && unitDoesCountTowardsCap u)
        |> Dict.size
        |> (\unitsCount -> unitsCount >= maxSubsPerTeam)


think : Float -> Game -> Base -> Delta
think dt game base =
    case base.maybeOccupied of
        Nothing ->
            deltaNone

        Just occupied ->
            if not occupied.isActive then
                deltaNone
            else
                deltaList
                    [ deltaBuildSub dt game base occupied
                    , deltaBuildAllMechs dt game base occupied
                    , deltaRepairEmbeddedSubs dt game base occupied
                    ]


deltaRepairEmbeddedSubs : Seconds -> Game -> Base -> BaseOccupied -> Delta
deltaRepairEmbeddedSubs dt game base occupied =
    if occupied.subBuildCompletion <= 0 then
        deltaNone
    else
        occupied.unitIds
            |> Set.toList
            |> List.filterMap (\id -> Dict.get id game.unitById)
            |> List.filter (\u -> u.integrity < 1)
            |> List.map
                (\u ->
                    deltaList
                        [ Base.deltaRepairUnit dt base.id u.id
                        , View.Gfx.deltaAddRepairBubbles 0.5 dt u.position
                        ]
                )
            |> deltaList


deltaBuildSub : Seconds -> Game -> Base -> BaseOccupied -> Delta
deltaBuildSub dt game base occupied =
    case occupied.maybeTeamId of
        Nothing ->
            deltaNone

        Just teamId ->
            let
                completionIncrease =
                    dt * subBuildSpeed * game.subBuildMultiplier
            in
            if occupied.subBuildCompletion + completionIncrease < 1 || teamHasReachedUnitCap game teamId then
                deltaBase base.id (Base.updateOccupied (\o -> { o | subBuildCompletion = o.subBuildCompletion + completionIncrease |> min 1 }))
            else
                deltaList
                    [ deltaBase base.id (Base.updateOccupied (\o -> { o | subBuildCompletion = 0 }))
                    , deltaGame (updateAddSub occupied.maybeTeamId base.position)
                    ]


updateAddSub : Maybe TeamId -> Vec2 -> Game -> Game
updateAddSub maybeTeamId position game =
    case maybeTeamId of
        Nothing ->
            game

        Just teamId ->
            let
                team =
                    getTeam game teamId

                spawnBigSub =
                    team.bigSubsToSpawn > 0
            in
            game
                |> Game.addSub maybeTeamId position spawnBigSub
                |> Tuple.first
                -- TODO clean this up
                |> updateTeam { team | bigSubsToSpawn = team.bigSubsToSpawn - 1 |> max 0 }


deltaBuildAllMechs : Seconds -> Game -> Base -> BaseOccupied -> Delta
deltaBuildAllMechs dt game base occupied =
    let
        completionIncrease =
            dt * mechBuildSpeed
    in
    occupied.mechBuildCompletions
        |> List.map (deltaBuildMech completionIncrease base occupied)
        |> deltaList


addFreshlyBuiltMech : MechComponent -> TeamId -> Vec2 -> Game -> Game
addFreshlyBuiltMech mech teamId position game =
    Game.addMech mech.class mech.inputKey (Just teamId) position game |> Tuple.first


markMechProductionComplete : MechComponent -> BaseOccupied -> BaseOccupied
markMechProductionComplete mech occupied =
    { occupied | mechBuildCompletions = List.filter (\( m, completion ) -> m /= mech) occupied.mechBuildCompletions }


deltaBuildMech : Float -> Base -> BaseOccupied -> ( MechComponent, Float ) -> Delta
deltaBuildMech completionIncrease base occupied ( mech, completionAtThink ) =
    case occupied.maybeTeamId of
        Nothing ->
            deltaNone

        Just teamId ->
            if completionAtThink + completionIncrease < 1 then
                let
                    increaseCompletion ( m, completionAtUpdate ) =
                        if m == mech then
                            ( m, completionAtUpdate + completionIncrease )
                        else
                            ( m, completionAtUpdate )
                in
                (\o -> { o | mechBuildCompletions = List.map increaseCompletion o.mechBuildCompletions })
                    |> Base.updateOccupied
                    |> deltaBase base.id
            else
                deltaList
                    [ deltaGame (addFreshlyBuiltMech mech teamId base.position)
                    , deltaBase base.id (Base.updateOccupied (markMechProductionComplete mech))
                    ]
