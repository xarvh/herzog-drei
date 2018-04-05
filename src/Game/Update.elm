module Game.Update exposing (..)

import Dict exposing (Dict)
import Game
    exposing
        ( Base
        , Delta(..)
        , Game
        , Id
        , Player
        , Projectile
        , Seconds
        , Unit
        , UnitMode(..)
        , normalizeAngle
        , tile2Vec
        , vec2Tile
        )
import Game.Player
import Game.Projectile
import Game.Unit
import Set exposing (Set)
import View.Gfx


-- Main update function


update : Seconds -> Dict Id Game.PlayerInput -> Game -> Game
update dt playerInputById game =
    let
        units =
            Dict.values game.unitById

        updatedUnpassableTiles =
            units
                |> List.map (.position >> vec2Tile)
                |> Set.fromList
                |> Set.union game.staticObstacles

        oldGameWithUpdatedUnpassableTiles =
            { game | unpassableTiles = updatedUnpassableTiles }

        getInputForPlayer player =
            playerInputById
                |> Dict.get player.id
                |> Maybe.withDefault Game.neutralPlayerInput

        playerThink player =
            Game.Player.think dt oldGameWithUpdatedUnpassableTiles (getInputForPlayer player) player
    in
    List.concat
        [ units
            |> List.map (Game.Unit.think dt oldGameWithUpdatedUnpassableTiles)
        , game.playerById
            |> Dict.values
            |> List.map playerThink
        , game.projectileById
            |> Dict.values
            |> List.map (Game.Projectile.think dt oldGameWithUpdatedUnpassableTiles)
        ]
        |> List.concat
        |> applyGameDelta oldGameWithUpdatedUnpassableTiles
        |> updateGfxs dt



-- Gfxs


updateGfxs : Seconds -> Game -> Game
updateGfxs dt game =
    { game | cosmetics = List.filterMap (View.Gfx.update dt) game.cosmetics }



-- Folder


{-| For each entity of type `a`, keep a list of functions that can mutate it
-}
type alias DeltaDict gameState entity =
    Dict Id (List (gameState -> entity -> entity))


ddEmpty : DeltaDict gameState entity
ddEmpty =
    Dict.empty


ddInsert : Id -> (gameState -> entity -> entity) -> DeltaDict gameState entity -> DeltaDict gameState entity
ddInsert id transform dd =
    let
        updatedList =
            case Dict.get id dd of
                Nothing ->
                    [ transform ]

                Just list ->
                    transform :: list
    in
    Dict.insert id updatedList dd


ddApply : gameState -> DeltaDict gameState entity -> Id -> entity -> entity
ddApply game dd id entity =
    case Dict.get id dd of
        Nothing ->
            entity

        Just transforms ->
            let
                -- need this to avoid https://github.com/elm-lang/elm-compiler/issues/1602
                apply : entity -> List (gameState -> entity -> entity) -> entity
                apply e list =
                    case list of
                        [] ->
                            e

                        fun :: xs ->
                            apply (fun game e) xs
            in
            apply entity transforms



--


type alias GameDeltaDicts =
    { bases : DeltaDict Game Base
    , players : DeltaDict Game Player
    , projectiles : DeltaDict Game Projectile
    , units : DeltaDict Game Unit
    , game : List (Game -> Game)
    }


applyGameDelta : Game -> List Delta -> Game
applyGameDelta game deltas =
    let
        foldDeltas : Delta -> GameDeltaDicts -> GameDeltaDicts
        foldDeltas delta deltaStuff =
            case delta of
                DeltaBase id f ->
                    { deltaStuff | bases = ddInsert id f deltaStuff.bases }

                DeltaPlayer id f ->
                    { deltaStuff | players = ddInsert id f deltaStuff.players }

                DeltaProjectile id f ->
                    { deltaStuff | projectiles = ddInsert id f deltaStuff.projectiles }

                DeltaUnit id f ->
                    { deltaStuff | units = ddInsert id f deltaStuff.units }

                DeltaGame f ->
                    { deltaStuff | game = f :: deltaStuff.game }

        emptyGameDeltaDicts : GameDeltaDicts
        emptyGameDeltaDicts =
            { bases = ddEmpty
            , players = ddEmpty
            , projectiles = ddEmpty
            , units = ddEmpty
            , game = []
            }

        deltaDicts : GameDeltaDicts
        deltaDicts =
            List.foldl foldDeltas emptyGameDeltaDicts deltas

        -- need this to avoid https://github.com/elm-lang/elm-compiler/issues/1602
        apply : List (Game -> Game) -> Game -> Game
        apply list g =
            case list of
                [] ->
                    g

                fun :: xs ->
                    -- TODO is this TCO-friendly?
                    apply xs (fun g)
    in
    { game
        | baseById = Dict.map (ddApply game deltaDicts.bases) game.baseById
        , playerById = Dict.map (ddApply game deltaDicts.players) game.playerById
        , projectileById = Dict.map (ddApply game deltaDicts.projectiles) game.projectileById
        , unitById = Dict.map (ddApply game deltaDicts.units) game.unitById
    }
        |> apply deltaDicts.game
