module Projectile exposing (..)

import Dict exposing (Dict)
import Game exposing (..)
import Stats


idToClass : ProjectileClassId -> ProjectileClass
idToClass id =
    case id of
        PlaneBullet ->
            Stats.bullet

        BigSubBullet ->
            Stats.bullet

        HeliRocket ->
            Stats.rocket


add : ProjectileSeed -> Game -> Game
add { maybeTeamId, position, angle, classId } game =
    let
        class =
            idToClass classId

        projectile =
            { id = game.lastId + 1
            , maybeTeamId = maybeTeamId
            , position = position
            , spawnPosition = position
            , spawnTime = game.time
            , angle = angle
            , classId = classId
            }

        projectileById =
            Dict.insert projectile.id projectile game.projectileById
    in
    { game | projectileById = projectileById, lastId = projectile.id }


deltaAdd : ProjectileSeed -> Delta
deltaAdd p =
    add p |> deltaGame


remove : Id -> Game -> Game
remove id game =
    { game | projectileById = Dict.remove id game.projectileById }


deltaRemove : Id -> Delta
deltaRemove id =
    remove id |> deltaGame
