module Base exposing (..)

import ColorPattern exposing (ColorPattern)
import Dict exposing (Dict)
import Game exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)


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
            base.position
                |> tile2Vec
                |> Vec2.toTuple

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
    squareArea (size base) base.position



-- utilities


add : BaseType -> Tile2 -> Game -> ( Game, Base )
add type_ position game =
    let
        id =
            game.lastId + 1

        base =
            { id = id
            , type_ = type_
            , isActive = False
            , containedUnits = 0
            , ownerId = -1
            , position = position
            , buildCompletion = 0
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
    playerColorPattern game base.ownerId


isNeutral : Game -> Base -> Bool
isNeutral game base =
    hasOwner game base |> not


hasOwner : Game -> Base -> Bool
hasOwner game base =
    Dict.member base.ownerId game.playerById
