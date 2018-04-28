module SubThink exposing (..)

{-| This module contains all the deltas that can be originated by Units
and the Unit.think that decudes which deltas to output.
-}

import AStar
import Base
import Dict exposing (Dict)
import Game exposing (..)
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Set exposing (Set)
import Unit
import View.Gfx
import View.Sub


-- Think


think : Float -> Game -> Unit -> SubComponent -> Delta
think dt game unit sub =
    DeltaList
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
            DeltaBase baseId (updateBaseLosesUnit unit.id)

        _ ->
            DeltaNone



-- Targeting


searchForTargets : Game -> Unit -> Maybe Delta
searchForTargets game unit =
    let
        ifCloseEnough ( target, distance ) =
            if distance > Unit.subShootRange then
                Nothing
            else
                (\sub -> { sub | maybeTargetId = Just target.id })
                    |> updateSub
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


thinkTarget : Float -> Game -> Unit -> SubComponent -> Delta
thinkTarget dt game unit sub =
    case sub.maybeTargetId |> Maybe.andThen (\id -> Dict.get id game.unitById) of
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
                DeltaList
                    [ DeltaUnit unit.id
                        (\g u ->
                            { u
                                | fireAngle = Game.turnTo (2 * pi * dt) (Game.vecToAngle dp) unit.fireAngle
                                , lookAngle = Game.turnTo (5 * pi * dt) (Game.vecToAngle dp) unit.lookAngle
                            }
                        )
                    , DeltaList <|
                        if unit.timeToReload > 0 || Vec2.lengthSquared dp > Unit.subShootRange ^ 2 then
                            []
                        else
                            [ DeltaUnit unit.id (\g u -> { u | timeToReload = Unit.subReloadTime })
                            , DeltaUnit target.id (Unit.takeDamage Unit.subShootDamage)
                            , View.Gfx.deltaAddBeam
                                (Vec2.add unit.position (View.Sub.gunOffset unit.moveAngle))
                                target.position
                                (Game.playerColorPattern game unit.ownerId)
                            ]
                    ]



-- Movement


getAvailableMovesLimitMapBoundaries : ( Int, Int ) -> Tile2 -> Set Tile2
getAvailableMovesLimitMapBoundaries ( halfWidth, halfHeight ) ( x, y ) =
    let
        add : Bool -> Tile2 -> Set Tile2 -> Set Tile2
        add condition tile =
            if condition then
                Set.insert tile
            else
                identity
    in
    Set.empty
        |> add (x > -halfWidth) ( x - 1, y )
        |> add (x < halfWidth) ( x + 1, y )
        |> add (y > -halfHeight) ( x, y - 1 )
        |> add (y < halfHeight) ( x, y + 1 )


getAvailableMoves : Game -> Tile2 -> Set Tile2
getAvailableMoves game tile =
    getAvailableMovesLimitMapBoundaries ( game.halfWidth, game.halfHeight ) tile
        |> flip Set.diff game.unpassableTiles


deltaMove : Float -> Game -> Vec2 -> Unit -> Delta
deltaMove dt game targetPosition unit =
    let
        setCooldown : Int -> Delta
        setCooldown counter =
          DeltaUnit unit.id (\g u -> { u | pathing = PathingCooldown counter })

        moveTo : Vec2 -> List Tile2 -> Delta
        moveTo target pathTail =
            updateMove unit.id dt target pathTail |> DeltaGame
    in
    if vectorDistance unit.position targetPosition < 0.01 then
        DeltaNone
    else if vec2Tile targetPosition == vec2Tile unit.position then
        moveTo targetPosition []
    else
        case unit.pathing of
            PathingFollow pathHead pathTail ->
                moveTo (tile2Vec pathHead) pathTail

            PathingNotNecessary ->
              setCooldown 1

            PathingCooldown counter ->
              if counter > 1 then
                setCooldown (counter - 1)
              else
                case AStar.findPath tileDistance (getAvailableMoves game) (vec2Tile unit.position) (vec2Tile targetPosition) 0 of
                    -- no path to target
                    [] ->
                        setCooldown 10

                    -- new path
                    pathHead :: pathTail ->
                        moveTo (tile2Vec pathHead) pathTail


updateMove : Id -> Seconds -> Vec2 -> List Tile2 -> Game -> Game
updateMove unitId dt nextPosition pathTail game =
    Game.withUnit game unitId <|
        \unit ->
            let
                speed =
                    1

                idealDeltaPosition =
                    Vec2.sub nextPosition unit.position

                viableDeltaPosition =
                    clampToRadius (speed * dt) idealDeltaPosition

                moveAngle =
                    Game.turnTo (2 * pi * dt) (Game.vecToAngle viableDeltaPosition) unit.moveAngle

                position =
                    Vec2.add unit.position viableDeltaPosition

                oldTile =
                    vec2Tile unit.position

                newTile =
                    vec2Tile position
            in
            if newTile /= oldTile && Set.member newTile game.unpassableTiles then
                -- destination tile occupied: don't move, reset path
                Game.updateUnit
                    { unit
                        | pathing = PathingCooldown 10
                        , moveAngle = moveAngle
                    }
                    game
            else
                let
                    nextTile =
                        vec2Tile nextPosition

                    pathing =
                        if newTile == nextTile then
                            PathingNotNecessary
                        else
                            PathingFollow nextTile pathTail
                in
                -- destination tile available, mark it as occupied and move unit
                Game.updateUnit
                    { unit
                        | position = position
                        , moveAngle = moveAngle
                        , pathing = pathing
                    }
                    { game | unpassableTiles = Set.insert newTile game.unpassableTiles }



{-
         let
             (pathHead, pathTail) =
               case unit.path of
                 [] ->
                   makeAStarPath




           let
               targetTile =
                 vec2Tile targetPosition

               unitTile =
                   vec2Tile unit.position
           in
               if targetTile == unitTile then
                 ---------------------------------- subtileMovement
               else
                 let
                      =
                     case unit.path of
                       [] -> makeAStarPath

                     let
                       path =
                     in
                         [ setAstarPath path
                         ,  List.head xs |> subTileMovementTowards
                         ]

               path =
                   []

               --                 AStar.findPath
               --                     tileDistance
               --                     (getAvailableMoves game.unpassableTiles)
               --                     unitTile
               --                     (vec2Tile targetPosition)
               --                     targetDistance
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

-}
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
            DeltaNone

        UnitModeFree ->
            {-
               Movement:
                 if base nearby && can be entered -> move / enter
                 else -> move to marker
            -}
            case Dict.get unit.ownerId game.playerById of
                Nothing ->
                    DeltaNone

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
                                deltaMove dt game base.position unit
                            else
                                DeltaGame (deltaGameUnitEntersBase unit.id base.id)

                        Nothing ->
                            deltaMove dt game player.markerPosition unit
