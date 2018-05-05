module VictoryThink exposing (..)

import Base
import Dict exposing (Dict)
import Game exposing (..)
import List.Extra


think : Seconds -> Game -> Delta
think dt game =
    if game.maybeWinnerId /= Nothing then
        deltaNone
    else
        let
            playersWithoutMainBases =
                game.playerById
                    |> Dict.values
                    |> List.filter (\player -> Base.playerMainBase game player.id == Nothing)
        in
        case playersWithoutMainBases of
            [] ->
                deltaNone

            [ oneLoser ] ->
                let
                    winnerId =
                        Dict.remove oneLoser.id game.playerById
                            |> Dict.values
                            |> List.head
                            |> Maybe.map .id
                            |> Maybe.withDefault -1
                in
                deltaGame (\g -> { g | maybeWinnerId = Just winnerId })

            _ ->
                -- mutual annhilation?
                deltaGame (\g -> { g | maybeWinnerId = Just -1 })
