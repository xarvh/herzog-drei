module Projectile exposing (..)

import Dict exposing (Dict)
import Game exposing (..)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
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

        HeliMissile ->
            Stats.missile

        UpwardSalvo ->
            Stats.upwardSalvo

        DownwardSalvo ->
            Stats.downwardSalvo


perspective : Seconds -> Float
perspective age =
    1



--+ 0.4 * age


addSpecial : Vec2 -> ProjectileSeed -> Game -> Game
addSpecial spawnPosition { maybeTeamId, position, angle, classId, maybeTargetId } game =
    let
        class =
            idToClass classId

        projectile =
            { id = game.lastId + 1
            , maybeTeamId = maybeTeamId
            , position = position
            , spawnPosition = spawnPosition
            , spawnTime = game.time
            , angle = angle
            , classId = classId
            , maybeTargetId = maybeTargetId
            }

        projectileById =
            Dict.insert projectile.id projectile game.projectileById
    in
    { game | projectileById = projectileById, lastId = projectile.id }


add : ProjectileSeed -> Game -> Game
add seed game =
    addSpecial seed.position seed game


deltaAdd : ProjectileSeed -> Delta
deltaAdd p =
    add p |> deltaGame


remove : Id -> Game -> Game
remove id game =
    { game | projectileById = Dict.remove id game.projectileById }


deltaRemove : Id -> Delta
deltaRemove id =
    remove id |> deltaGame
