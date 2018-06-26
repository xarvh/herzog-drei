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
        { x, y } =
            Vec2.toRecord base.position

        r =
            toFloat (size base.type_ // 2) - 0.2
    in
    [ vec2 (x + r) (y + r)
    , vec2 (x - r) (y + r)
    , vec2 (x - r) (y - r)
    , vec2 (x + r) (y - r)
    ]



-- rules


size : BaseType -> Int
size baseType =
    case baseType of
        BaseSmall ->
            2

        BaseMain ->
            4


tiles : BaseType -> Tile2 -> List Tile2
tiles baseType tile =
    squareArea (size baseType) tile


unitCanEnter : Unit -> Base -> Bool
unitCanEnter unit base =
    case base.maybeOccupied of
        Nothing ->
            True

        Just occupied ->
            occupied.maybeTeamId == unit.maybeTeamId && Set.size occupied.unitIds < maxContainedUnits



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
        |> addStaticObstacles (tiles type_ tile)
    , base
    )


colorPattern : Game -> Base -> ColorPattern
colorPattern game base =
    teamColorPattern game <|
        case base.maybeOccupied of
            Just occupied ->
                if occupied.isActive then
                    occupied.maybeTeamId
                else
                    Nothing

            Nothing ->
                Nothing


isOccupied : Base -> Bool
isOccupied base =
    base.maybeOccupied /= Nothing


isOccupiedBy : Maybe TeamId -> Base -> Bool
isOccupiedBy maybeTeamId base =
    case base.maybeOccupied of
        Nothing ->
            False

        Just occupied ->
            occupied.maybeTeamId == maybeTeamId


teamMainBase : Game -> Maybe TeamId -> Maybe Base
teamMainBase game maybeTeamId =
    game.baseById
        |> Dict.values
        |> List.Extra.find (\b -> b.type_ == BaseMain && isOccupiedBy maybeTeamId b)


updateOccupied : (BaseOccupied -> BaseOccupied) -> Game -> Base -> Base
updateOccupied update game base =
    { base | maybeOccupied = Maybe.map update base.maybeOccupied }


deltaRepairUnit : Seconds -> Id -> Id -> Delta
deltaRepairUnit dt baseId unitId =
    deltaGame <|
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
                                                    ( 0.3, 0.3 )

                                                UnitSub _ ->
                                                    ( 0.2, 1.0 )

                                        -- Don't need to repair beyond integrity 1
                                        requirementLimit =
                                            1 - unit.integrity

                                        -- Limit speed
                                        timeLimit =
                                            repairRate * dt

                                        -- Can't use more than the base has
                                        baseLimit =
                                            occupied.subBuildCompletion * productionToIntegrityRatio

                                        --
                                        actualRepair =
                                            1.0
                                                |> min requirementLimit
                                                |> min timeLimit
                                                |> min baseLimit

                                        updatedUnit =
                                            { unit | integrity = unit.integrity + actualRepair }

                                        updatedBase =
                                            { base | maybeOccupied = Just { occupied | subBuildCompletion = occupied.subBuildCompletion - actualRepair / productionToIntegrityRatio } }
                                    in
                                    game
                                        |> Game.updateBase updatedBase
                                        |> Game.updateUnit updatedUnit
