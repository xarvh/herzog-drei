module Base exposing (..)

import ColorPattern exposing (ColorPattern)
import Dict exposing (Dict)
import Game exposing (..)
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Set exposing (Set)


-- constants


maximumDistanceForUnitToEnterBase : Float
maximumDistanceForUnitToEnterBase =
    2.1



-- corners


maxContainedUnits : Int
maxContainedUnits =
    4


corners : Base -> List Vec2
corners base =
    let
        ( x, y ) =
            Vec2.toTuple base.position

        r =
            toFloat (size base // 2) - 0.2
    in
    [ vec2 (x + r) (y + r)
    , vec2 (x - r) (y + r)
    , vec2 (x - r) (y - r)
    , vec2 (x + r) (y - r)
    ]



-- rules


size : Base -> Int
size base =
    case base.type_ of
        BaseSmall ->
            2

        BaseMain ->
            4


tiles : Base -> List Tile2
tiles base =
    squareArea (size base) base.tile


unitCanEnter : Unit -> Base -> Bool
unitCanEnter unit base =
    case base.maybeOccupied of
        Nothing ->
            True

        Just occupied ->
            occupied.playerId == unit.ownerId && Set.size occupied.unitIds < maxContainedUnits



-- utilities


add : BaseType -> Tile2 -> Game -> ( Game, Base )
add type_ tile game =
    let
        id =
            game.lastId + 1

        base =
            { id = id
            , type_ = type_
            , maybeOccupied = Nothing
            , tile = tile
            , position = tile2Vec tile
            }
    in
    ( { game
        | lastId = id
        , baseById = Dict.insert id base game.baseById
      }
        |> addStaticObstacles (tiles base)
    , base
    )


colorPattern : Game -> Base -> ColorPattern
colorPattern game base =
    playerColorPattern game <|
        case base.maybeOccupied of
            Just occupied ->
                if occupied.isActive then
                    occupied.playerId
                else
                    -1

            Nothing ->
                -1


isOccupied : Base -> Bool
isOccupied base =
    base.maybeOccupied /= Nothing


isOccupiedBy : Id -> Base -> Bool
isOccupiedBy playerId base =
    case base.maybeOccupied of
        Nothing ->
            False

        Just occupied ->
            occupied.playerId == playerId


playerMainBase : Game -> Id -> Maybe Base
playerMainBase game playerId =
    game.baseById
        |> Dict.values
        |> List.Extra.find (\b -> b.type_ == BaseMain && isOccupiedBy playerId b)


updateOccupied : (BaseOccupied -> BaseOccupied) -> Game -> Base -> Base
updateOccupied update game base =
    { base | maybeOccupied = Maybe.map update base.maybeOccupied }


deltaRepairUnit : Seconds -> Id -> Id -> Delta
deltaRepairUnit dt baseId unitId =
    DeltaGame <|
        \game ->
            Game.withBase game baseId <|
                \base ->
                    case base.maybeOccupied of
                        Nothing ->
                            game

                        Just occupied ->
                            Game.withUnit game unitId <|
                                \unit ->
                                    let
                                        ( repairRate, productionToIntegrityRatio ) =
                                            case unit.component of
                                                UnitMech _ ->
                                                    ( 0.3, 1.0 )

                                                UnitSub _ ->
                                                    ( 0.1, 3.0 )

                                        -- Don't need to repair beyond integrity 1
                                        requirementLimit =
                                            1 - unit.integrity

                                        -- Limit speed
                                        timeLimit =
                                            repairRate * dt

                                        -- Can't use more than the base has
                                        baseLimit =
                                            occupied.buildCompletion * productionToIntegrityRatio

                                        --
                                        actualRepair =
                                            1.0
                                                |> min requirementLimit
                                                |> min timeLimit
                                                |> min baseLimit

                                        updatedUnit =
                                            { unit | integrity = unit.integrity + actualRepair }

                                        updatedBase =
                                            { base | maybeOccupied = Just { occupied | buildCompletion = occupied.buildCompletion - actualRepair / productionToIntegrityRatio } }
                                    in
                                    game
                                        |> Game.updateBase updatedBase
                                        |> Game.updateUnit updatedUnit
