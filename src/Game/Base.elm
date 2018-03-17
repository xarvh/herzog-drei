module Game.Base exposing (..)

import Dict exposing (Dict)
import Game exposing (Base, Id, Tile2)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Set exposing (Set)


add : Id -> Tile2 -> Dict Id Base -> Dict Id Base
add id position =
    Dict.insert id
        { id = id
        , containedUnits = 0
        , maybeOwnerId = Nothing
        , position = position
        }


tiles : Base -> Set Tile2
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
        |> Set.fromList
