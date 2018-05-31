module Bot.Dummy exposing (State, init, update)

import Base
import Dict exposing (Dict)
import Game exposing (..)
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Random
import Unit


type alias State =
    { inputKey : String
    , teamId : TeamId
    , basesSortedByPriority : List Id
    , hasHumanAlly : Bool
    , randomSeed : Random.Seed
    , speedAroundBase : Float
    , lastChange : Seconds
    }


init : String -> TeamId -> Bool -> Int -> Game -> State
init inputKey teamId hasHumanAlly randomInteger game =
    let
        mainBasePosition =
            game.baseById
                |> Dict.values
                |> List.Extra.find (\base -> base.type_ == BaseMain && Base.isOccupiedBy (Just teamId) base)
                |> Maybe.map .position
                |> Maybe.withDefault (vec2 0 0)

        basesSortedByPriority =
            game.baseById
                |> Dict.values
                |> List.sortBy (\base -> vectorDistance base.position mainBasePosition)
                |> List.map .id
    in
    { inputKey = inputKey
    , teamId = teamId
    , basesSortedByPriority = basesSortedByPriority
    , hasHumanAlly = hasHumanAlly
    , randomSeed = Random.initialSeed randomInteger

    -- 1 means anti-clockwise
    , speedAroundBase = 1
    , lastChange = game.time
    }


update : Game -> State -> ( State, InputState )
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
                            if Base.isOccupiedBy (Just state.teamId) base then
                                pickTargetBase bs
                            else
                                Just base
    in
    case pickTargetBase state.basesSortedByPriority of
        Nothing ->
            -- Bot owns all the bases!
            gloat game state

        Just targetBase ->
            attackBase state game targetBase


gloat : Game -> State -> ( State, InputState )
gloat game state =
    ( if game.time - state.lastChange < 0.01 then
        state
      else
        { state
            | lastChange = game.time
            , speedAroundBase = state.speedAroundBase + 0.1
        }
    , { inputStateNeutral
        | fire = True
        , transform = True
        , aim = angleToVector state.speedAroundBase |> AimAbsolute
      }
    )


attackBase : State -> Game -> Base -> ( State, InputState )
attackBase state game targetBase =
    case Unit.findMech state.inputKey (Dict.values game.unitById) of
        Nothing ->
            -- You're dead, you can't do anything
            ( state, inputStateNeutral )

        Just ( playerUnit, playerMech ) ->
            let
                ( aim, fire ) =
                    shootEnemies playerUnit game

                ( newState, { transform, rally, move } ) =
                    moveToTargetBase playerUnit playerMech state game targetBase
            in
            ( newState
            , { aim = aim
              , fire = fire
              , transform = transform
              , rally = rally && not state.hasHumanAlly
              , switchUnit = False
              , move = move
              }
            )


shootEnemies : Unit -> Game -> ( Aim, Bool )
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
                |> List.filter (\u -> u.maybeTeamId /= playerUnit.maybeTeamId)
                |> List.filterMap closeEnough
                |> List.Extra.minimumBy Tuple.second
    in
    case maybeUnitAndDistance of
        Nothing ->
            ( AimAbsolute (vec2 0 0), False )

        Just ( targetUnit, distance ) ->
            ( Vec2.sub targetUnit.position playerUnit.position |> Vec2.normalize |> AimAbsolute, True )


moveToTargetBase : Unit -> MechComponent -> State -> Game -> Base -> ( State, { transform : Bool, rally : Bool, move : Vec2 } )
moveToTargetBase playerUnit playerMech state game base =
    let
        safeDistance =
            game.unitById
                |> Dict.values
                |> List.filter (\u -> u.maybeTeamId /= playerUnit.maybeTeamId && vectorDistance u.position base.position < 6)
                |> List.length
                |> toFloat
                |> sqrt
                |> (+) 4
    in
    if vectorDistance playerUnit.position base.position > safeDistance then
        ( state
        , { transform = playerMech.transformingTo /= ToPlane
          , rally = False
          , move = Vec2.sub base.position playerUnit.position |> Vec2.normalize
          }
        )
    else
        let
            ( doChangeDirection, seed ) =
                if game.time - state.lastChange < 0.2 then
                    ( False, state.randomSeed )
                else
                    Random.step (Random.float 0 1 |> Random.map (\n -> n < 0.03)) state.randomSeed

            ( speedAroundBase, lastChange ) =
                if doChangeDirection then
                    ( -state.speedAroundBase, game.time )
                else
                    ( state.speedAroundBase, state.lastChange )
        in
        ( { state
            | randomSeed = seed
            , lastChange = lastChange
            , speedAroundBase = speedAroundBase
          }
        , { transform = playerMech.transformingTo /= ToMech
          , rally = True
          , move = Vec2.sub base.position playerUnit.position |> rotateVector (state.speedAroundBase * pi / 2) |> Vec2.normalize
          }
        )
