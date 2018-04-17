module BaseThink exposing (..)

import Dict exposing (Dict)
import Game
    exposing
        ( Base
        , Delta(..)
        , Game
        , Id
        , Tile2
        , Unit
        , UnitType(..)
        , UnitTypeMechRecord
        , UnitTypeSubRecord
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
    case base.maybeOwnerId of
        Nothing ->
            DeltaList []

        Just ownerId ->
            let
                buildCompletion =
                    base.buildCompletion + dt * buildSpeed |> min 1
            in
            if buildCompletion < 1 || playerReachedUnitCapacity ownerId game then
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
                    , DeltaGame (\g -> Game.addUnit ownerId False position g |> Tuple.first)
                    ]
