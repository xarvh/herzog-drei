module Bot.Dummy exposing (..)

import Game exposing (..)


type alias State =
    {}


init : State
init =
    {}


update : Game -> State -> ( State, PlayerInput )
update game state =
    ( state, { neutralPlayerInput | fire = True } )
