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
import Projectile
import Random
import Set exposing (Set)
import Stats
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
        , thinkRegenerate dt game unit sub
        ]



--


thinkRegenerate : Seconds -> Game -> Unit -> SubComponent -> Delta
thinkRegenerate dt game unit sub =
    if not sub.isBig || unit.integrity >= 1 then
        deltaNone
    else
        let
            repair =
                0.03 * dt
        in
        deltaList
            [ View.Gfx.deltaAddRepairBubbles 0.3 dt unit.position
            , deltaUnit unit.id (\g u -> { u | integrity = u.integrity + repair |> min 1 })
            ]



-- Destroy


destroy : Game -> Unit -> SubComponent -> Delta
destroy game unit sub =
    case sub.mode of
        UnitModeBase baseId ->
            DeltaNeedsUpdatedGame (deltaBaseLosesUnit unit.id baseId)

        _ ->
            deltaNone


deltaBaseLosesUnit : Id -> Id -> Game -> Delta
deltaBaseLosesUnit unitId baseId game =
    case Dict.get baseId game.baseById of
        Nothing ->
            deltaNone

        Just base ->
            case base.maybeOccupied of
                Nothing ->
                    deltaNone

                Just occupied ->
                    if occupied.unitIds /= Set.singleton unitId then
                        Base.deltaOccupied baseId (\o -> { o | unitIds = Set.remove unitId o.unitIds })
                    else if base.type_ /= BaseMain then
                        deltaBase baseId (\g b -> { b | maybeOccupied = Nothing })
                    else
                        deltaList
                            [ deltaDefeat occupied.maybeTeamId
                            , deltaExplosions base.position
                            , View.Gfx.deltaAddFrags game 400 base.position occupied.maybeTeamId
                            , deltaLater 0.6 (deltaGame (\g -> { g | baseById = Dict.remove base.id g.baseById }))
                            , deltaSlowMotionBig
                            ]



-- Victory and defeat


deltaDefeat : Maybe TeamId -> Delta
deltaDefeat maybeTeamId =
    case maybeTeamId of
        Nothing ->
            deltaNone

        Just defeatedTeamId ->
            let
                winnerTeamId =
                    case defeatedTeamId of
                        TeamLeft ->
                            TeamRight

                        TeamRight ->
                            TeamLeft
            in
            deltaGame (\g -> { g | maybeVictory = Just ( winnerTeamId, g.time ) })


deltaExplosions : Vec2 -> Delta
deltaExplosions position =
    let
        skewedFloat =
            Random.float 0 1 |> Random.map (\n -> n ^ 4)

        delayGenerator =
            Random.float 0.1 5

        sizeGenerator =
            Random.float 0.5 5

        dpGenerator =
            Random.float -2 2

        positionGenerator =
            Random.pair dpGenerator dpGenerator
                |> Random.map (\( dx, dy ) -> Vec2.add position (vec2 dx dy))

        deltaSecondary size pos =
            deltaList
                [ View.Gfx.deltaAddExplosion pos size
                , deltaShake (0.1 * size)
                ]

        deltaRandomSecondary =
            deltaRandom2 deltaSecondary sizeGenerator positionGenerator
    in
    deltaList
        [ View.Gfx.deltaAddExplosion position 20
        , deltaShake 0.5
        , delayGenerator
            |> deltaRandom (\delay -> deltaLater delay deltaRandomSecondary)
            |> List.repeat 50
            |> deltaList
        ]



-- Targeting


searchForTargets : Game -> Unit -> SubComponent -> Maybe Delta
searchForTargets game unit sub =
    let
        ifCloseEnough ( target, priority ) =
            if vectorDistance unit.position target.position > Stats.subShootRange sub then
                Nothing
            else
                (\s -> { s | targetId = target.id })
                    |> updateSub
                    |> deltaUnit unit.id
                    |> Just

        targetPriority distance target =
            if sub.isBig then
                case target.component of
                    UnitMech mech ->
                        -8

                    UnitSub s ->
                        case s.mode of
                            UnitModeBase baseId ->
                                -8

                            UnitModeFree ->
                                -distance
            else
                case target.component of
                    UnitMech mech ->
                        1

                    UnitSub s ->
                        case s.mode of
                            UnitModeBase baseId ->
                                2

                            UnitModeFree ->
                                -distance

        validTargetPriority target =
            if target.maybeTeamId == unit.maybeTeamId then
                Nothing
            else
                let
                    distance =
                        vectorDistance unit.position target.position
                in
                if distance > Stats.subShootRange sub then
                    Nothing
                else
                    Just ( target, targetPriority distance target )

        setTarget ( target, priority ) =
            (\s -> { s | targetId = target.id })
                |> updateSub
                |> deltaUnit unit.id
    in
    game.unitById
        |> Dict.values
        |> List.filterMap validTargetPriority
        |> List.Extra.maximumBy Tuple.second
        |> Maybe.map setTarget


unitAlignsAimToMovement : Float -> Unit -> Delta
unitAlignsAimToMovement dt unit =
    deltaUnit unit.id
        (\g u ->
            { u
                | lookAngle = Game.turnTo (5 * pi * dt) unit.moveAngle unit.lookAngle
                , fireAngle = Game.turnTo (2 * pi * dt) unit.moveAngle unit.fireAngle
            }
        )


searchForTargetOrAlignToMovement : Float -> Game -> Unit -> SubComponent -> Delta
searchForTargetOrAlignToMovement dt game unit sub =
    case searchForTargets game unit sub of
        Just delta ->
            delta

        Nothing ->
            unitAlignsAimToMovement dt unit


thinkTarget : Float -> Game -> Unit -> SubComponent -> Delta
thinkTarget dt game unit sub =
    case Dict.get sub.targetId game.unitById of
        Nothing ->
            searchForTargetOrAlignToMovement dt game unit sub

        Just target ->
            if vectorDistance unit.position target.position > Stats.subShootRange sub then
                searchForTargetOrAlignToMovement dt game unit sub
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
                        if game.time < unit.reloadEndTime || Vec2.lengthSquared dp > Stats.subShootRange sub ^ 2 then
                            []
                        else
                            [ deltaUnit unit.id (\g u -> { u | reloadEndTime = game.time + Stats.subReloadTime sub })
                            , let
                                origin =
                                    Vec2.add unit.position (View.Sub.gunOffset unit.moveAngle)

                                damage =
                                    Stats.subShootDamage sub
                              in
                              case sub.isBig of
                                False ->
                                    deltaList
                                        [ deltaUnit target.id (Unit.takeDamage damage)
                                        , View.Gfx.deltaAddBeam
                                            origin
                                            target.position
                                            (Game.teamColorPattern game unit.maybeTeamId)
                                        ]

                                True ->
                                    Projectile.deltaAdd
                                        { maybeTeamId = unit.maybeTeamId
                                        , position = origin
                                        , angle = unit.fireAngle
                                        , classId = BigSubBullet
                                        , maybeTargetId = Nothing
                                        }
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
                |> List.Extra.find (\t -> not <| Set.member t game.dynamicObstacles)
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
            if currentTilePosition /= newTilePosition && Set.member newTilePosition game.dynamicObstacles then
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

                    dynamicObstacles =
                        Set.insert newTilePosition game.dynamicObstacles
                in
                { game | dynamicObstacles = dynamicObstacles }
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
                    , maybeTeamId = unit.maybeTeamId
                    , subBuildCompletion = 0
                    , mechBuildCompletions = []
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
                case maybeGetTeam game unit.maybeTeamId of
                    Nothing ->
                        deltaNone

                    Just team ->
                        if sub.isBig then
                            -- big subs never enter in bases
                            movePath dt game team.pathing unit
                        else
                            let
                                conquerBaseDistanceThreshold =
                                    3.0

                                baseDistance base =
                                    vectorDistance base.position unit.position - toFloat (Base.size base.type_ // 2)

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
                                    movePath dt game team.pathing unit
