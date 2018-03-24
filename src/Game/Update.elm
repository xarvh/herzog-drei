module Game.Update exposing (..)

import Dict exposing (Dict)
import Game
    exposing
        ( Base
        , Delta(..)
        , Game
        , Id
        , Laser
        , Player
        , Unit
        , UnitMode(..)
        , normalizeAngle
        , tile2Vec
        , vec2Tile
        )
import Game.Player
import Game.Unit
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Set exposing (Set)
import UnitSvg


-- Setters


updateBase : Base -> Game -> Game
updateBase base game =
    { game | baseById = Dict.insert base.id base game.baseById }


updatePlayer : Player -> Game -> Game
updatePlayer player game =
    { game | playerById = Dict.insert player.id player game.playerById }


updateUnit : Unit -> Game -> Game
updateUnit unit game =
    { game | unitById = Dict.insert unit.id unit game.unitById }


addLaser : Laser -> Game -> Game
addLaser laser game =
    { game | lasers = laser :: game.lasers }



-- Main update function


update : Float -> Dict Id Game.PlayerInput -> Game -> Game
update dt playerInputById oldGame =
    let
        units =
            Dict.values oldGame.unitById

        updatedUnpassableTiles =
            units
                |> List.map (.position >> vec2Tile)
                |> Set.fromList
                |> Set.union oldGame.staticObstacles

        oldGameWithUpdatedUnpassableTiles =
            { oldGame | unpassableTiles = updatedUnpassableTiles }

        getInputForPlayer player =
            playerInputById
                |> Dict.get player.id
                |> Maybe.withDefault Game.neutralPlayerInput

        playerThink player =
            Game.Player.think dt oldGameWithUpdatedUnpassableTiles (getInputForPlayer player) player
    in
    List.concat
        [ units
            |> List.map (Game.Unit.think dt oldGameWithUpdatedUnpassableTiles)
        , oldGame.playerById
            |> Dict.values
            |> List.map playerThink
        ]
        |> List.concat
        |> List.foldl applyGameDelta oldGameWithUpdatedUnpassableTiles
        |> updateLasers dt



-- Lasers


updateLaser : Float -> Laser -> Laser
updateLaser dt laser =
    { laser | age = laser.age + dt }


updateLasers : Float -> Game -> Game
updateLasers dt game =
    { game
        | lasers =
            game.lasers
                |> List.map (updateLaser dt)
                |> List.filter (\laser -> laser.age < UnitSvg.laserLifeSpan)
    }



-- Folder


applyGameDelta : Delta -> Game -> Game
applyGameDelta delta game =
    let
        with : (Game -> Dict Id a) -> Id -> (a -> Game) -> Game
        with getter id fn =
            case Dict.get id (getter game) of
                Nothing ->
                    game

                Just item ->
                    fn item

        withBase =
            with .baseById

        withPlayer =
            with .playerById

        withUnit =
            with .unitById
    in
    case delta of
        PlayerMoves playerId dp ->
            Game.Player.move playerId dp game

        MarkerMoves playerId newPosition ->
            withPlayer playerId <|
                \player ->
                    updatePlayer { player | markerPosition = newPosition } game

        UnitMoves unitId movementAngle dx ->
            withUnit unitId <|
                \unit -> deltaUnitMoves movementAngle dx unit game

        UnitEntersBase unitId baseId ->
            withUnit unitId <|
                \unit ->
                    withBase baseId <|
                        \base -> deltaUnitEntersBase unit base game

        UnitAttackCooldown unitId timeToReload ->
            withUnit unitId <|
                \unit ->
                    updateUnit { unit | timeToReload = timeToReload } game

        UnitAcquiresTarget unitId targetId ->
            withUnit unitId <|
                \unit ->
                    updateUnit { unit | maybeTargetId = Just targetId } game

        UnitAims unitId targetingAngle ->
            withUnit unitId <|
                \unit ->
                    updateUnit { unit | targetingAngle = targetingAngle } game

        UnitShoots unitId timeToReload targetId ->
            withUnit unitId <|
                \unit ->
                    withUnit targetId <|
                        \target ->
                            game
                                |> updateUnit
                                    { unit
                                        | targetingAngle = Game.vecToAngle (Vec2.sub target.position unit.position)
                                        , timeToReload = timeToReload
                                    }
                                |> addLaser
                                    { start = Vec2.add unit.position (UnitSvg.gunOffset unit.movementAngle)
                                    , end = target.position
                                    , age = 0
                                    , colorPattern = Game.playerColorPattern game unit.ownerId
                                    }



-- Deltas


deltaUnitMoves : Float -> Vec2 -> Unit -> Game -> Game
deltaUnitMoves movementAngle dx unit game =
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
            |> updateUnit newUnit


deltaUnitEntersBase : Unit -> Base -> Game -> Game
deltaUnitEntersBase unit base game =
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
                    |> updateUnit newUnit
                    |> updateBase newBase
