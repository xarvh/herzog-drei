module Bot.Dummy exposing (State, init, update)

import Base
import Dict exposing (Dict)
import Game exposing (..)
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Unit


type alias State =
    { playerId : Id
    , basesSortedByPriority : List Id
    }


init : Id -> Game -> State
init playerId game =
    let
        mainBasePosition =
            game.baseById
                |> Dict.values
                |> List.Extra.find (\base -> base.type_ == BaseMain && Base.isOccupiedBy playerId base)
                |> Maybe.map .position
                |> Maybe.withDefault (vec2 0 0)

        basesSortedByPriority =
            game.baseById
                |> Dict.values
                |> List.sortBy (\base -> vectorDistance base.position mainBasePosition)
                |> List.map .id
    in
    { playerId = playerId
    , basesSortedByPriority = basesSortedByPriority
    }


update : Game -> State -> ( State, PlayerInput )
update game state =
    let
        pickTargetBase : List Id -> Maybe Base
        pickTargetBase baseIds =
            case baseIds of
                [] ->
                    Nothing

                baseId :: bs ->
                    case Dict.get baseId game.baseById of
                        Nothing ->
                            Nothing

                        Just base ->
                            if Base.isOccupiedBy state.playerId base then
                                pickTargetBase bs
                            else
                                Just base
    in
    case pickTargetBase state.basesSortedByPriority of
        Nothing ->
            -- Bot owns all the bases!
            gloat game state

        Just targetBase ->
            ( state, attackBase state.playerId game targetBase )


gloat : Game -> State -> ( State, PlayerInput )
gloat game state =
    -- TODO: do something more gloaty
    ( state, { neutralPlayerInput | fire = True } )


attackBase : Id -> Game -> Base -> PlayerInput
attackBase playerId game targetBase =
    case Unit.findMech playerId (Dict.values game.unitById) of
        Nothing ->
            -- You're dead, you can't do anything
            neutralPlayerInput

        Just ( playerUnit, playerMech ) ->
            let
                ( aim, fire ) =
                    shootEnemies playerUnit game

                { transform, rally, move } =
                    moveToTargetBase playerUnit playerMech game targetBase
            in
            { aim = aim
            , fire = fire
            , transform = transform
            , rally = rally
            , switchUnit = False
            , move = move
            }


shootEnemies : Unit -> Game -> ( Vec2, Bool )
shootEnemies playerUnit game =
    let
        closeEnough : Unit -> Maybe ( Unit, Float )
        closeEnough unit =
            let
                distance =
                    vectorDistance unit.position playerUnit.position
            in
            if distance <= Unit.mechShootRange then
                Just ( unit, distance )
            else
                Nothing

        maybeUnitAndDistance =
            game.unitById
                |> Dict.values
                |> List.filter (\u -> u.ownerId /= playerUnit.ownerId)
                |> List.filterMap closeEnough
                |> List.Extra.minimumBy Tuple.second
    in
    case maybeUnitAndDistance of
        Nothing ->
            ( vec2 0 0, False )

        Just ( targetUnit, distance ) ->
            ( Vec2.sub targetUnit.position playerUnit.position |> Vec2.normalize, True )


moveToTargetBase : Unit -> MechComponent -> Game -> Base -> { transform : Bool, rally : Bool, move : Vec2 }
moveToTargetBase playerUnit playerMech game base =
    let
        safeDistance =
            game.unitById
                |> Dict.values
                |> List.filter (\u -> u.ownerId /= playerUnit.ownerId && vectorDistance u.position base.position < 6)
                |> List.length
                |> toFloat
                |> sqrt
                |> (+) 4
    in
    if vectorDistance playerUnit.position base.position > safeDistance then
        { transform = playerMech.transformingTo /= ToPlane
        , rally = False
        , move = Vec2.sub base.position playerUnit.position |> Vec2.normalize
        }
    else
        { transform = playerMech.transformingTo /= ToMech
        , rally = True
        , move = Vec2.sub base.position playerUnit.position |> rotateVector (pi / 2) |> Vec2.normalize
        }
