module Stats exposing (..)

import Game exposing (..)


-- Projectiles


bullet : ProjectileClass
bullet =
    { speed = 30
    , range = 8
    , effect = ProjectileDamage 4
    , trail = False
    , accelerates = False
    }


rocket : ProjectileClass
rocket =
    { speed = 0
    , range = 8
    , effect = ProjectileSplashDamage { radius = 3, damage = 10 }
    , trail = True
    , accelerates = True
    }



-- Subs constants


subReloadTime : SubComponent -> Seconds
subReloadTime sub =
    if sub.isBig then
        0.4
    else
        4.0


subShootRange : SubComponent -> Float
subShootRange sub =
    if sub.isBig then
        8.0
    else
        7.0


subShootDamage : SubComponent -> number
subShootDamage sub =
    if sub.isBig then
        4
    else
        11



-- Mech constants


blimp =
    { beamDamage = 40
    , beamRange = 10
    , reload = 1.0
    }


heli =
    { walkReload = 0.5
    , flyReload = 0.75
    }


plane =
    { walkReload = 0.05
    , flyReload = 0.075
    }
