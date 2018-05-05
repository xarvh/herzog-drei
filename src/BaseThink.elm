module BaseThink exposing (..)

import Base
import Dict exposing (Dict)
import Game exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Set exposing (Set)
import Unit


maxSubsPerPlayer =
    30



-- Think


buildSpeed : BaseOccupied -> Float
buildSpeed occupied =
    case occupied.buildTarget of
        BuildSub ->
            0.2

        BuildMech ->
            0.1


playerHasReachedUnitCap : Game -> Id -> Bool
playerHasReachedUnitCap game playerId =
    game.unitById
        |> Dict.filter (\id u -> Unit.isSub u && u.ownerId == playerId)
        |> Dict.size
        |> (\unitsCount -> unitsCount >= maxSubsPerPlayer)
        -- Prevent neutral bases from spawning
        |> (||) (not <| Dict.member playerId game.playerById)


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
                    [ deltaBuildProgress dt game base occupied
                    , deltaRepairEmbeddedSubs dt game base occupied
                    ]


deltaRepairEmbeddedSubs : Seconds -> Game -> Base -> BaseOccupied -> Delta
deltaRepairEmbeddedSubs dt game base occupied =
    if occupied.buildCompletion <= 0 then
        deltaNone
    else
        occupied.unitIds
            |> Set.toList
            |> List.filterMap (\id -> Dict.get id game.unitById)
            |> List.filter (\u -> u.integrity < 1)
            |> List.map (\u -> Base.deltaRepairUnit dt base.id u.id)
            |> deltaList


deltaBuildProgress : Seconds -> Game -> Base -> BaseOccupied -> Delta
deltaBuildProgress dt game base occupied =
    let
        completionIncrease =
            dt * buildSpeed occupied
    in
    if occupied.buildCompletion + completionIncrease < 1 || (occupied.buildTarget == BuildSub && playerHasReachedUnitCap game occupied.playerId) then
        deltaBase base.id (Base.updateOccupied (\o -> { o | buildCompletion = o.buildCompletion + completionIncrease |> min 1 }))
    else
        let
            position =
                Vec2.add base.position (vec2 3 0)
        in
        deltaList
            [ deltaBase base.id (Base.updateOccupied (\o -> { o | buildCompletion = 0 }))
            , case occupied.buildTarget of
                BuildSub ->
                    deltaGame (\g -> Game.addSub occupied.playerId position g |> Tuple.first)

                BuildMech ->
                    deltaList
                        [ deltaGame (\g -> Game.addMech occupied.playerId base.position g |> Tuple.first)
                        , deltaBase base.id (Base.updateOccupied <| \o -> { o | buildTarget = BuildSub })
                        ]
            ]
