module BaseThink exposing (..)

import Base
import Dict exposing (Dict)
import Game exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)


-- Think


buildSpeed base =
    case base.buildTarget of
        BuildSub ->
            0.2

        BuildMech ->
            0.1


playerReachedUnitCapacity : Id -> Game -> Bool
playerReachedUnitCapacity playerId game =
    let
        unitsCount =
            game.unitById |> Dict.filter (\id u -> u.ownerId == playerId) |> Dict.size
    in
    unitsCount >= 20


think : Float -> Game -> Base -> Delta
think dt game base =
    if Base.isNeutral game base then
        DeltaNone
    else
        let
            buildCompletion =
                base.buildCompletion + dt * buildSpeed base |> min 1
        in
        if buildCompletion < 1 || (base.buildTarget == BuildSub && playerReachedUnitCapacity base.ownerId game) then
            DeltaBase base.id (\g b -> { b | buildCompletion = buildCompletion })
        else
            let
                position =
                    base.position
                        |> Game.tile2Vec
                        |> Vec2.add (vec2 3 0)
            in
            DeltaList
                [ DeltaBase base.id (\g b -> { b | buildCompletion = 0 })
                , case base.buildTarget of
                    BuildSub ->
                        DeltaGame (\g -> Game.addSub base.ownerId position g |> Tuple.first)

                    BuildMech ->
                        DeltaList
                            [ DeltaGame (\g -> Game.addMech base.ownerId position g |> Tuple.first)
                            , DeltaBase base.id (\g b -> { b | buildTarget = BuildSub })
                            ]
                ]
