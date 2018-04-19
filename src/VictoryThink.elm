module VictoryThink exposing (..)

import Dict exposing (Dict)
import Game exposing (..)
import List.Extra


think : Seconds -> Game -> Delta
think dt game =
    if game.maybeWinnerId /= Nothing then
        DeltaList []
    else
        let
            mainBases =
                game.baseById
                    |> Dict.values
                    |> List.filter (\b -> b.type_ == BaseMain)

            isOwnedBy : Player -> Base -> Bool
            isOwnedBy player base =
                base.ownerId == player.id

            playersWithoutMainBases =
                game.playerById
                    |> Dict.values
                    |> List.filter (\player -> List.Extra.find (isOwnedBy player) mainBases == Nothing)
        in
        case playersWithoutMainBases of
            [] ->
                DeltaList []

            [ oneLoser ] ->
                let
                    winnerId =
                        Dict.remove oneLoser.id game.playerById
                            |> Dict.values
                            |> List.head
                            |> Maybe.map .id
                            |> Maybe.withDefault -1
                in
                DeltaGame (\g -> { g | maybeWinnerId = Just winnerId })

            _ ->
                -- mutual annhilation?
                DeltaGame (\g -> { g | maybeWinnerId = Just -1 })
