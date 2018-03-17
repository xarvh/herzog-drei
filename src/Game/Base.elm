module Game.Base exposing (..)

import Dict exposing (Dict)
import Game exposing (Game, Base, Id, Tile2)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Set exposing (Set)


add : Tile2 -> Game -> ( Game, Base )
add position game =
    let
        id =
            game.lastId + 1

        base =
            { id = id
            , isActive = False
            , containedUnits = 0
            , maybeOwnerId = Nothing
            , position = position
            }

        baseById =
            Dict.insert id base game.baseById

        staticObstacles =
            Set.union (tiles base |> Set.fromList) game.staticObstacles
    in
    ( { game | lastId = id, staticObstacles = staticObstacles, baseById = baseById }, base )


tiles : Base -> List Tile2
tiles base =
    let
        ( x, y ) =
            base.position
    in
    [ ( x + 0, y - 1 )
    , ( x - 1, y - 1 )
    , ( x - 1, y + 0 )
    , ( x + 0, y + 0 )
    ]
