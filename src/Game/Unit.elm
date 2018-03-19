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
        , UnitOrder(..)
        , UnitStatus(..)
        , clampToRadius
        , tile2Vec
        , tileDistance
        , vec2Tile
        , vectorDistance
        )
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Set exposing (Set)


add : Id -> Vec2 -> Game -> ( Game, Unit )
add ownerId position game =
    let
        id =
            game.lastId + 1

        unit =
            { id = id
            , ownerId = ownerId
            , order = UnitOrderFollowMarker
            , status = Game.UnitStatusFree
            , movementAngle = 0
            , targetingAngle = 0
            , maybeTargetId = Nothing
            , position = position
            }

        unitById =
            Dict.insert id unit game.unitById
    in
    ( { game | lastId = id, unitById = unitById }, unit )


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


move : Float -> Game -> Vec2 -> Unit -> Maybe Delta
move dt game targetPosition unit =
    let
        targetDistance =
            0
    in
    if vectorDistance unit.position targetPosition <= targetDistance then
        Nothing
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
        Just (MoveUnit unit.id movementAngle viableDelta)



-- Think


think : Float -> Game -> Unit -> List Delta
think dt game unit =
    [ Just <| thinkTarget dt game unit
    , thinkMovement dt game unit
    ]
        |> List.filterMap identity


unitSearchForTargets : Game -> Unit -> Maybe Delta
unitSearchForTargets game unit =
    let
        ifCloseEnough ( u, distance ) =
            if distance > Game.unitAttackRange then
                Nothing
            else
                Just (SetUnitTarget unit.id u.id)
    in
    game.unitById
        |> Dict.values
        |> List.filter (\u -> u.ownerId /= unit.ownerId)
        |> List.map (\u -> ( u, Game.vectorDistance unit.position u.position ))
        |> List.Extra.minimumBy Tuple.second
        |> Maybe.andThen ifCloseEnough


unitAlignsAimToMovement : Float -> Unit -> Delta
unitAlignsAimToMovement dt unit =
    UnitAims unit.id (Game.turnTo (2 * pi * dt) unit.movementAngle unit.targetingAngle)


thinkTarget : Float -> Game -> Unit -> Delta
thinkTarget dt game unit =
    case unit.maybeTargetId |> Maybe.andThen (\id -> Dict.get id game.unitById) of
        Just target ->
            if vectorDistance unit.position target.position > Game.unitAttackRange then
                -- if target is too far, search for targets
                unitSearchForTargets game unit
                    |> Maybe.withDefault (unitAlignsAimToMovement dt unit)
            else
                let
                    dp =
                        Vec2.sub target.position unit.position

                    targetingAngle =
                        Game.turnTo (2 * pi * dt) (Game.vecToAngle dp) unit.targetingAngle
                in
                -- TODO shoot!
                UnitAims unit.id targetingAngle

        Nothing ->
            unitSearchForTargets game unit
                |> Maybe.withDefault (unitAlignsAimToMovement dt unit)


thinkMovement : Float -> Game -> Unit -> Maybe Delta
thinkMovement dt game unit =
    case unit.status of
        UnitStatusInBase baseId ->
            Nothing

        UnitStatusFree ->
            case unit.order of
                UnitOrderStay ->
                    Nothing

                UnitOrderEnterBase baseId ->
                    case Dict.get baseId game.baseById of
                        Nothing ->
                            Nothing

                        Just base ->
                            if vectorDistance unit.position (tile2Vec base.position) > Game.maximumDistanceForUnitToEnterBase then
                                move dt game (tile2Vec base.position) unit
                            else
                                Just (UnitEntersBase unit.id base.id)

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
                            Nothing

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
                                        Just (UnitEntersBase unit.id base.id)

                                Nothing ->
                                    move dt game player.markerPosition unit
