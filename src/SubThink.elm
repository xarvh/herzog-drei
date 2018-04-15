module SubThink exposing (..)

{-| This module contains all the deltas that can be originated by Units
and the Unit.think that decudes which deltas to output.
-}

import AStar
import Dict exposing (Dict)
import Game
    exposing
        ( Base
        , Delta(..)
        , Game
        , Id
        , Tile2
        , Unit
        , UnitMode(..)
        , UnitType(..)
        , UnitTypeSubRecord
        , clampToRadius
        , tile2Vec
        , tileDistance
        , updateUnitSubRecord
        , vec2Tile
        , vectorDistance
        )
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Set exposing (Set)
import View.Gfx
import View.Unit


-- Constants


unitReloadTime : Float
unitReloadTime =
    5.0


unitShootRange : Float
unitShootRange =
    7.0



-- Think


think : Float -> Game -> Unit -> UnitTypeSubRecord -> Delta
think dt game unit subRecord =
    DeltaList
        [ thinkTarget dt game unit subRecord
        , thinkMovement dt game unit subRecord
        ]



-- Destroy


deltaBaseLosesUnit : Game -> Base -> Base
deltaBaseLosesUnit game base =
    let
        containedUnits =
            base.containedUnits - 1

        maybeOwnerId =
            if containedUnits < 1 then
                Nothing
            else
                base.maybeOwnerId
    in
    { base | maybeOwnerId = maybeOwnerId, containedUnits = containedUnits }


destroy : Game -> Unit -> UnitTypeSubRecord -> Delta
destroy game unit subRecord =
    case subRecord.mode of
        UnitModeBase baseId ->
            DeltaBase baseId deltaBaseLosesUnit

        _ ->
            DeltaList []



-- Targeting


searchForTargets : Game -> Unit -> Maybe Delta
searchForTargets game unit =
    let
        ifCloseEnough ( target, distance ) =
            if distance > unitShootRange then
                Nothing
            else
                (\subRecord -> { subRecord | maybeTargetId = Just target.id })
                    |> updateUnitSubRecord
                    |> DeltaUnit unit.id
                    |> Just
    in
    game.unitById
        |> Dict.values
        |> List.filter (\u -> u.ownerId /= unit.ownerId)
        |> List.map (\u -> ( u, Game.vectorDistance unit.position u.position ))
        |> List.Extra.minimumBy Tuple.second
        |> Maybe.andThen ifCloseEnough


unitAlignsAimToMovement : Float -> Unit -> Delta
unitAlignsAimToMovement dt unit =
    DeltaUnit unit.id
        (\g u ->
            { u
                | lookAngle = Game.turnTo (5 * pi * dt) unit.moveAngle unit.lookAngle
                , fireAngle = Game.turnTo (2 * pi * dt) unit.moveAngle unit.fireAngle
            }
        )


searchForTargetOrAlignToMovement : Float -> Game -> Unit -> Delta
searchForTargetOrAlignToMovement dt game unit =
    case searchForTargets game unit of
        Just delta ->
            delta

        Nothing ->
            unitAlignsAimToMovement dt unit


thinkTarget : Float -> Game -> Unit -> UnitTypeSubRecord -> Delta
thinkTarget dt game unit subRecord =
    case subRecord.maybeTargetId |> Maybe.andThen (\id -> Dict.get id game.unitById) of
        Nothing ->
            searchForTargetOrAlignToMovement dt game unit

        Just target ->
            if vectorDistance unit.position target.position > unitShootRange then
                searchForTargetOrAlignToMovement dt game unit
            else
                let
                    dp =
                        Vec2.sub target.position unit.position
                in
                DeltaList
                    [ DeltaUnit unit.id
                        (\g u ->
                            { u
                                | fireAngle = Game.turnTo (2 * pi * dt) (Game.vecToAngle dp) unit.fireAngle
                                , lookAngle = Game.turnTo (5 * pi * dt) (Game.vecToAngle dp) unit.lookAngle
                            }
                        )
                    , DeltaList <|
                        if unit.timeToReload > 0 || Vec2.lengthSquared dp > unitShootRange ^ 2 then
                            []
                        else
                            [ DeltaUnit unit.id (\g u -> { u | timeToReload = unitReloadTime })
                            , DeltaUnit target.id (deltaUnitTakeDamage 1)
                            , View.Gfx.deltaAddBeam
                                (Vec2.add unit.position (View.Unit.gunOffset unit.moveAngle))
                                target.position
                                (Game.playerColorPattern game unit.ownerId)
                            ]
                    ]


deltaUnitTakeDamage : Int -> Game -> Unit -> Unit
deltaUnitTakeDamage damage game unit =
    { unit | hp = unit.hp - damage }



-- Movement


getAvailableMoves : Set Tile2 -> Tile2 -> Set Tile2
getAvailableMoves occupiedPositions ( x, y ) =
    [ if x > -5 then
        [ ( x - 1, y ) ]
      else
        []
    , if x < 4 then
        [ ( x + 1, y ) ]
      else
        []
    , if y > -5 then
        [ ( x, y - 1 ) ]
      else
        []
    , if y < 4 then
        [ ( x, y + 1 ) ]
      else
        []
    ]
        |> List.concat
        |> List.filter (\pos -> not <| Set.member pos occupiedPositions)
        |> Set.fromList


move : Float -> Game -> Vec2 -> Unit -> Delta
move dt game targetPosition unit =
    let
        targetDistance =
            0
    in
    if vectorDistance unit.position targetPosition <= targetDistance then
        DeltaList []
    else
        let
            unitTile =
                vec2Tile unit.position

            path =
                AStar.findPath
                    tileDistance
                    (getAvailableMoves game.unpassableTiles)
                    unitTile
                    (vec2Tile targetPosition)
                    targetDistance

            idealDelta =
                case path of
                    [] ->
                        Vec2.sub targetPosition unit.position

                    head :: tail ->
                        Vec2.sub (tile2Vec head) (tile2Vec unitTile)

            speed =
                1

            maxLength =
                speed * dt

            viableDelta =
                clampToRadius maxLength idealDelta

            moveAngle =
                Game.turnTo (2 * pi * dt) (Game.vecToAngle viableDelta) unit.moveAngle
        in
        DeltaGame (deltaGameUnitMoves unit.id moveAngle viableDelta)


deltaGameUnitMoves : Id -> Float -> Vec2 -> Game -> Game
deltaGameUnitMoves unitId moveAngle dx game =
    Game.withUnit game unitId <|
        \unit ->
            let
                newPosition =
                    Vec2.add unit.position dx

                currentTilePosition =
                    vec2Tile unit.position

                newTilePosition =
                    vec2Tile newPosition
            in
            if currentTilePosition /= newTilePosition && Set.member newTilePosition game.unpassableTiles then
                -- destination tile occupied, don't move
                game
            else
                -- destination tile available, mark it as occupied and move unit
                let
                    newUnit =
                        { unit | position = newPosition, moveAngle = moveAngle }

                    unpassableTiles =
                        Set.insert newTilePosition game.unpassableTiles
                in
                { game | unpassableTiles = unpassableTiles }
                    |> Game.updateUnit newUnit



-- Enter base


unitIsInBase : Id -> Unit -> Bool
unitIsInBase baseId unit =
    case unit.type_ of
        UnitTypeSub subRecord ->
            subRecord.mode == UnitModeBase baseId

        _ ->
            False


deltaGameUnitEntersBase : Id -> Id -> Game -> Game
deltaGameUnitEntersBase unitId baseId game =
    -- TODO: Game.with2 game (unitId, .unitById) (baseId, .baseById) <| \(unit, base) ->
    Game.withUnit game unitId <|
        \unit ->
            Game.withBase game baseId <|
                \base ->
                    if base.maybeOwnerId /= Nothing && base.maybeOwnerId /= Just unit.ownerId then
                        game
                    else
                        let
                            corners =
                                Game.baseCorners base

                            unitsInBase =
                                game.unitById
                                    |> Dict.values
                                    |> List.filter (unitIsInBase base.id)

                            takenCorners =
                                unitsInBase
                                    |> List.map .position
                        in
                        case List.Extra.find (\c -> not (List.member c takenCorners)) corners of
                            Nothing ->
                                game

                            Just corner ->
                                let
                                    containedUnits =
                                        1 + List.length takenCorners

                                    newUnit =
                                        unit
                                            |> updateUnitSubRecord (\s -> { s | mode = Game.UnitModeBase base.id }) game
                                            |> (\u -> { u | position = corner })

                                    newBase =
                                        { base
                                            | containedUnits = containedUnits
                                            , isActive = base.isActive || containedUnits == List.length corners
                                            , maybeOwnerId = Just unit.ownerId
                                        }
                                in
                                game
                                    |> Game.updateUnit newUnit
                                    |> Game.updateBase newBase


thinkMovement : Float -> Game -> Unit -> UnitTypeSubRecord -> Delta
thinkMovement dt game unit subRecord =
    case subRecord.mode of
        UnitModeBase baseId ->
            DeltaList []

        UnitModeFree ->
            {-
               Movement:
                 if base nearby && can be entered -> move / enter
                 else -> move to marker
            -}
            case Dict.get unit.ownerId game.playerById of
                Nothing ->
                    DeltaList []

                Just player ->
                    let
                        conquerBaseDistanceThreshold =
                            3.0

                        baseDistance base =
                            vectorDistance (tile2Vec base.position) unit.position - toFloat (Game.baseSize base // 2)

                        baseIsConquerable base =
                            baseDistance base
                                < conquerBaseDistanceThreshold
                                && (base.maybeOwnerId == Nothing || base.maybeOwnerId == Just unit.ownerId)
                                && (base.containedUnits < Game.baseMaxContainedUnits)
                    in
                    case List.Extra.find baseIsConquerable (Dict.values game.baseById) of
                        Just base ->
                            if baseDistance base > Game.maximumDistanceForUnitToEnterBase then
                                move dt game (tile2Vec base.position) unit
                            else
                                DeltaGame (deltaGameUnitEntersBase unit.id base.id)

                        Nothing ->
                            move dt game player.markerPosition unit
