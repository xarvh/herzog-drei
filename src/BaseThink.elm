module BaseThink exposing (..)

import Base
import Dict exposing (Dict)
import Game
    exposing
        ( Base
        , Delta(..)
        , Game
        , Id
        , Tile2
        , Unit
        , UnitComponent(..)
        )
import Math.Vector2 as Vec2 exposing (Vec2, vec2)


-- Think


buildSpeed =
    0.2


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
        DeltaList []
    else
        let
            buildCompletion =
                base.buildCompletion + dt * buildSpeed |> min 1
        in
        if buildCompletion < 1 || playerReachedUnitCapacity base.ownerId game then
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
                , DeltaGame (\g -> Game.addSub base.ownerId position g |> Tuple.first)
                ]
