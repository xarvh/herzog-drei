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
    , travelsAlongZ = False
    }


rocket : ProjectileClass
rocket =
    { speed = 0
    , range = 8
    , effect = ProjectileSplashDamage { radius = 3, damage = 10 }
    , trail = True
    , accelerates = True
    , travelsAlongZ = False
    }


upwardSalvo : ProjectileClass
upwardSalvo =
    { speed = 40
    , range = 40
    , effect = ProjectileDamage 0
    , trail = True
    , accelerates = True
    , travelsAlongZ = True
    }


downwardSalvo : ProjectileClass
downwardSalvo =
    { speed = 20
    , range = 20
    , effect = ProjectileSplashDamage { radius = 4, damage = 20 }
    , trail = True
    , accelerates = True
    , travelsAlongZ = True
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


transformTime =
    0.5


blimp =
    { beamDamage = 40
    , beamRange = 10
    , reload = 1.0
    , vampireRange = 3
    }


heli =
    { walkReload = 0.5
    , flyReload = 0.75
    , chargeTime = 2
    , stretchTime = 1.5
    , salvoSize = 10
    , cooldown = 0.5
    }


plane =
    { walkReload = 0.05
    , flyReload = 0.075
    , repairRange = 5
    }
