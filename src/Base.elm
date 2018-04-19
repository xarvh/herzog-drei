module Base exposing (..)

import Dict exposing (Dict)
import Game exposing (..)


isNeutral : Game -> Base -> Bool
isNeutral game base =
    hasOwner game base |> not


hasOwner : Game -> Base -> Bool
hasOwner game base =
    Dict.member base.ownerId game.playerById
