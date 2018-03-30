module Game.Unit exposing (..)

import AStar
import Dict exposing (Dict)
import Game
    exposing
        ( Delta(..)
        , Game
        , Id
        , Tile2
        , Unit
        , UnitMode(..)
        , UnitOrder(..)
        , clampToRadius
        , tile2Vec
        , tileDistance
        , vec2Tile
        , vectorDistance
        )
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Set exposing (Set)
import UnitSvg


-- Constants


unitReloadTime : Float
unitReloadTime =
    5.0


unitShootRange : Float
unitShootRange =
    7.0



-- Add


add : Id -> Vec2 -> Game -> ( Game, Unit )
add ownerId position game =
    let
        id =
            game.lastId + 1

        unit =
            { id = id
            , mode = Game.UnitModeFree
            , ownerId = ownerId
            , order = UnitOrderFollowMarker

            --
            , movementAngle = 0
            , position = position

            --
            , maybeTargetId = Nothing
            , targetingAngle = 0
            , timeToReload = 0
            }

        unitById =
            Dict.insert id unit game.unitById
    in
    ( { game | lastId = id, unitById = unitById }, unit )



-- Think


think : Float -> Game -> Unit -> List Delta
think dt game unit =
    List.concat
        [ thinkTarget dt game unit
        , thinkReload dt game unit
        , thinkMovement dt game unit
        ]



-- Reloading


thinkReload : Float -> Game -> Unit -> List Delta
thinkReload dt game unit =
    if unit.timeToReload > 0 then
        let
            timeToReload =
                max 0 (unit.timeToReload - dt)
        in
        [ DeltaUnit unit.id (\g u -> { u | timeToReload = timeToReload }) ]
    else
        []



-- Targeting


searchForTargets : Game -> Unit -> Maybe Delta
searchForTargets game unit =
    let
        ifCloseEnough ( target, distance ) =
            if distance > unitShootRange then
                Nothing
            else
                Just <| DeltaUnit unit.id (\g u -> { u | maybeTargetId = Just target.id })
    in
    game.unitById
        |> Dict.values
        |> List.filter (\u -> u.ownerId /= unit.ownerId)
        |> List.map (\u -> ( u, Game.vectorDistance unit.position u.position ))
        |> List.Extra.minimumBy Tuple.second
        |> Maybe.andThen ifCloseEnough


unitAlignsAimToMovement : Float -> Unit -> Delta
unitAlignsAimToMovement dt unit =
    let
        targetingAngle =
            Game.turnTo (2 * pi * dt) unit.movementAngle unit.targetingAngle
    in
    DeltaUnit unit.id (\g u -> { u | targetingAngle = targetingAngle })


searchForTargetOrAlignToMovement : Float -> Game -> Unit -> Delta
searchForTargetOrAlignToMovement dt game unit =
    case searchForTargets game unit of
        Just delta ->
            delta

        Nothing ->
            unitAlignsAimToMovement dt unit


thinkTarget : Float -> Game -> Unit -> List Delta
thinkTarget dt game unit =
    case unit.maybeTargetId |> Maybe.andThen (\id -> Dict.get id game.unitById) of
        Nothing ->
            [ searchForTargetOrAlignToMovement dt game unit ]

        Just target ->
            if vectorDistance unit.position target.position > unitShootRange then
                [ searchForTargetOrAlignToMovement dt game unit ]
            else
                let
                    dp =
                        Vec2.sub target.position unit.position

                    targetingAngle =
                        Game.turnTo (2 * pi * dt) (Game.vecToAngle dp) unit.targetingAngle
                in
                if unit.timeToReload > 0 || Vec2.lengthSquared dp > unitShootRange ^ 2 then
                    [ DeltaUnit unit.id (\g u -> { u | targetingAngle = targetingAngle }) ]
                else
                    [ DeltaUnit unit.id (deltaUnitShoot targetingAngle)
                    , DeltaGame <|
                        Game.addLaser
                            { start = Vec2.add unit.position (UnitSvg.gunOffset unit.movementAngle)
                            , end = target.position
                            , age = 0
                            , colorPattern = Game.playerColorPattern game unit.ownerId
                            }
                    ]


deltaUnitShoot : Float -> Game -> Unit -> Unit
deltaUnitShoot targetingAngle game unit =
    { unit
        | targetingAngle = targetingAngle
        , timeToReload = unitReloadTime
    }



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


move : Float -> Game -> Vec2 -> Unit -> List Delta
move dt game targetPosition unit =
    let
        targetDistance =
            0
    in
    if vectorDistance unit.position targetPosition <= targetDistance then
        []
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

            movementAngle =
                Game.turnTo (2 * pi * dt) (Game.vecToAngle viableDelta) unit.movementAngle
        in
        [ DeltaGame (deltaGameUnitMoves unit.id movementAngle viableDelta)
        ]


deltaGameUnitMoves : Id -> Float -> Vec2 -> Game -> Game
deltaGameUnitMoves unitId movementAngle dx game =
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
                        { unit | position = newPosition, movementAngle = movementAngle }

                    unpassableTiles =
                        Set.insert newTilePosition game.unpassableTiles
                in
                { game | unpassableTiles = unpassableTiles }
                    |> Game.updateUnit newUnit



-- Enter base


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
                                    |> List.filter (\u -> u.mode == UnitModeBase base.id)

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
                                        { unit
                                            | mode = Game.UnitModeBase base.id
                                            , position = corner
                                        }

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


thinkMovement : Float -> Game -> Unit -> List Delta
thinkMovement dt game unit =
    case unit.mode of
        UnitModeBase baseId ->
            []

        UnitModeFree ->
            case unit.order of
                UnitOrderStay ->
                    []

                UnitOrderEnterBase baseId ->
                    case Dict.get baseId game.baseById of
                        Nothing ->
                            []

                        Just base ->
                            if vectorDistance unit.position (tile2Vec base.position) > Game.maximumDistanceForUnitToEnterBase then
                                move dt game (tile2Vec base.position) unit
                            else
                                [ DeltaGame (deltaGameUnitEntersBase unit.id base.id) ]

                UnitOrderMoveTo targetPosition ->
                    move dt game targetPosition unit

                {-
                   Movement:
                     if base nearby && can be entered -> move / enter
                     else -> move to marker
                -}
                UnitOrderFollowMarker ->
                    case Dict.get unit.ownerId game.playerById of
                        Nothing ->
                            []

                        Just player ->
                            let
                                conquerBaseDistanceThreshold =
                                    3.0

                                baseDistance base =
                                    vectorDistance (tile2Vec base.position) unit.position

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
                                        [ DeltaGame (deltaGameUnitEntersBase unit.id base.id) ]

                                Nothing ->
                                    move dt game player.markerPosition unit
