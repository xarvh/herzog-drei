module SubThink exposing (..)

{-| This module contains all the deltas that can be originated by Units
and the Unit.think that decudes which deltas to output.
-}

import Base
import Dict exposing (Dict)
import Game exposing (..)
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Pathfinding
import Set exposing (Set)
import Unit
import View.Gfx
import View.Sub


subSpeed =
    1.0



-- Think


think : Float -> Game -> Unit -> SubComponent -> Delta
think dt game unit sub =
    deltaList
        [ thinkTarget dt game unit sub
        , thinkMovement dt game unit sub
        ]



-- Destroy


updateBaseLosesUnit : Id -> Game -> Base -> Base
updateBaseLosesUnit unitId game base =
    case base.maybeOccupied of
        Nothing ->
            base

        Just occupied ->
            let
                unitIds =
                    Set.remove unitId occupied.unitIds
            in
            { base
                | maybeOccupied =
                    if unitIds == Set.empty then
                        Nothing
                    else
                        Just { occupied | unitIds = unitIds }
            }


destroy : Game -> Unit -> SubComponent -> Delta
destroy game unit sub =
    case sub.mode of
        UnitModeBase baseId ->
            deltaBase baseId (updateBaseLosesUnit unit.id)

        _ ->
            deltaNone



-- Targeting


searchForTargets : Game -> Unit -> Maybe Delta
searchForTargets game unit =
    let
        ifCloseEnough ( target, distance ) =
            if distance > Unit.subShootRange then
                Nothing
            else
                (\sub -> { sub | targetId = target.id })
                    |> updateSub
                    |> deltaUnit unit.id
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
    deltaUnit unit.id
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


thinkTarget : Float -> Game -> Unit -> SubComponent -> Delta
thinkTarget dt game unit sub =
    case Dict.get sub.targetId game.unitById of
        Nothing ->
            searchForTargetOrAlignToMovement dt game unit

        Just target ->
            if vectorDistance unit.position target.position > Unit.subShootRange then
                searchForTargetOrAlignToMovement dt game unit
            else
                let
                    dp =
                        Vec2.sub target.position unit.position
                in
                deltaList
                    [ deltaUnit unit.id
                        (\g u ->
                            { u
                                | fireAngle = Game.turnTo (2 * pi * dt) (Game.vecToAngle dp) unit.fireAngle
                                , lookAngle = Game.turnTo (5 * pi * dt) (Game.vecToAngle dp) unit.lookAngle
                            }
                        )
                    , deltaList <|
                        if unit.timeToReload > 0 || Vec2.lengthSquared dp > Unit.subShootRange ^ 2 then
                            []
                        else
                            [ deltaUnit unit.id (\g u -> { u | timeToReload = Unit.subReloadTime })
                            , deltaUnit target.id (Unit.takeDamage Unit.subShootDamage)
                            , View.Gfx.deltaAddBeam
                                (Vec2.add unit.position (View.Sub.gunOffset unit.moveAngle))
                                target.position
                                (Game.playerColorPattern game unit.ownerId)
                            ]
                    ]



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
        deltaNone
    else
        let
            unitTile =
                vec2Tile unit.position

            idealDelta =
                Vec2.sub targetPosition unit.position

            maxLength =
                subSpeed * dt

            viableDelta =
                clampToRadius maxLength idealDelta

            moveAngle =
                Game.turnTo (2 * pi * dt) (Game.vecToAngle viableDelta) unit.moveAngle
        in
        deltaGame (deltaGameUnitMoves unit.id moveAngle viableDelta)


movePath : Float -> Game -> Dict Tile2 Float -> Unit -> Delta
movePath dt game paths unit =
    let
        unitTile =
            vec2Tile unit.position

        maybeTile =
            Pathfinding.moves game unitTile paths
                |> List.Extra.find (\t -> not <| Set.member t game.unpassableTiles)
    in
    case maybeTile of
        Nothing ->
            deltaNone

        Just targetTile ->
            move dt game (tile2Vec targetTile) unit


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
                        { unit
                            | position = newPosition
                            , moveAngle = moveAngle
                        }

                    unpassableTiles =
                        Set.insert newTilePosition game.unpassableTiles
                in
                { game | unpassableTiles = unpassableTiles }
                    |> Game.updateUnit newUnit



-- Enter base


unitIsInBase : Id -> Unit -> Bool
unitIsInBase baseId unit =
    case unit.component of
        UnitSub sub ->
            sub.mode == UnitModeBase baseId

        _ ->
            False


deltaGameUnitEntersBase : Id -> Id -> Game -> Game
deltaGameUnitEntersBase unitId baseId game =
    -- TODO: Game.with2 game (unitId, .unitById) (baseId, .baseById) <| \(unit, base) ->
    Game.withUnit game unitId <|
        \unit ->
            Game.withBase game baseId <|
                \base ->
                    if Base.unitCanEnter unit base then
                        updateUnitEntersBase unit base game
                    else
                        game


updateUnitEntersBase : Unit -> Base -> Game -> Game
updateUnitEntersBase unit base game =
    let
        originalOccupied =
            case base.maybeOccupied of
                Nothing ->
                    { unitIds = Set.empty
                    , isActive = False
                    , playerId = unit.ownerId
                    , buildCompletion = 0
                    , buildTarget = BuildSub
                    }

                Just occupied ->
                    occupied

        unitsInBase =
            originalOccupied.unitIds
                |> Set.toList
                |> List.filterMap (\id -> Dict.get id game.unitById)

        baseCorners =
            Base.corners base

        takenCorners =
            unitsInBase |> List.map .position
    in
    case List.Extra.find (\corner -> not (List.member corner takenCorners)) baseCorners of
        Nothing ->
            -- This should not happen -_-
            game

        Just corner ->
            let
                unitIds =
                    Set.insert unit.id originalOccupied.unitIds

                occupied =
                    { originalOccupied
                        | unitIds = unitIds
                        , isActive = originalOccupied.isActive || Set.size unitIds >= Base.maxContainedUnits
                    }

                angle =
                    Vec2.sub corner base.position |> Game.vecToAngle

                updatedUnit =
                    unit
                        |> updateSub (\s -> { s | mode = Game.UnitModeBase base.id }) game
                        |> (\u -> { u | position = corner, moveAngle = angle })

                updatedBase =
                    { base | maybeOccupied = Just occupied }
            in
            game
                |> Game.updateUnit updatedUnit
                |> Game.updateBase updatedBase


thinkMovement : Float -> Game -> Unit -> SubComponent -> Delta
thinkMovement dt game unit sub =
    case sub.mode of
        UnitModeBase baseId ->
            deltaNone

        UnitModeFree ->
            if unit.isLeavingBase then
                deltaUnit unit.id <|
                    if Set.member (vec2Tile unit.position) game.staticObstacles then
                        \g u -> { u | position = Vec2.add u.position (Vec2.scale (dt * subSpeed) (angleToVector unit.moveAngle)) }
                    else
                        \g u -> { u | isLeavingBase = False }
            else
                {-
                   Movement:
                     if base nearby && can be entered -> move / enter
                     else -> move to marker
                -}
                case Dict.get unit.ownerId game.playerById of
                    Nothing ->
                        deltaNone

                    Just player ->
                        let
                            conquerBaseDistanceThreshold =
                                3.0

                            baseDistance base =
                                vectorDistance base.position unit.position - toFloat (Base.size base // 2)

                            baseIsConquerable base =
                                (baseDistance base < conquerBaseDistanceThreshold) && Base.unitCanEnter unit base
                        in
                        case List.Extra.find baseIsConquerable (Dict.values game.baseById) of
                            Just base ->
                                if baseDistance base > Base.maximumDistanceForUnitToEnterBase then
                                    move dt game base.position unit
                                else
                                    deltaGame (deltaGameUnitEntersBase unit.id base.id)

                            Nothing ->
                                movePath dt game player.pathing unit
