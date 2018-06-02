module VictoryThink exposing (..)

import Base
import Dict exposing (Dict)
import Game exposing (..)
import List.Extra


think : Seconds -> Game -> Delta
think dt game =
    if game.maybeWinnerTeamId /= Nothing then
        deltaNone
    else
        let
            teamHasNoBases team =
                Base.teamMainBase game (Just team.id) == Nothing

            deltaWinner team =
                deltaGame (\g -> { g | maybeWinnerTeamId = Just team.id })
        in
        -- Playing left team is slightly more natural,
        -- so on mutual annhilation right team wins
        if teamHasNoBases game.leftTeam then
            deltaWinner game.rightTeam
        else if teamHasNoBases game.rightTeam then
            deltaWinner game.leftTeam
        else
            deltaNone
