module Stats exposing (..)

import Game exposing (..)


-- Heights
-- mech + base < 1


maxHeight =
    { sub = 0.2
    , mech = 0.3
    , wall = 0.4
    , base = 0.5
    , projectile = 0.6
    }



-- Projectiles


bullet : ProjectileClass
bullet =
    { speed = 30
    , range = 8
    , effect = ProjectileDamage 4
    , trail = False
    , acceleration = 0
    , travelsAlongZ = False
    }


rocket : ProjectileClass
rocket =
    { speed = 0
    , range = 8
    , effect = ProjectileSplashDamage { radius = 3, damage = 12 }
    , trail = True
    , acceleration = 30
    , travelsAlongZ = False
    }


missile : ProjectileClass
missile =
    { speed = 10
    , range = 8
    , effect = ProjectileSplashDamage { radius = 2, damage = 30 }
    , trail = True
    , acceleration = 0
    , travelsAlongZ = False
    }


upwardSalvo : ProjectileClass
upwardSalvo =
    { speed = 40
    , range = 40
    , effect = ProjectileDamage 0
    , trail = True
    , acceleration = 30
    , travelsAlongZ = True
    }


downwardSalvo : ProjectileClass
downwardSalvo =
    { speed = 20
    , range = 20
    , effect = ProjectileSplashDamage { radius = 5, damage = 25 }
    , trail = True
    , acceleration = 30
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
    { walkReload = 0.9
    , flyReload = 0.5
    , chargeTime = 2
    , maxStretchTime = 1.5
    , salvoSize = 10
    , cooldown = 0.5
    }


plane =
    { walkReload = 0.05
    , flyReload = 0.05
    , repairRange = 5
    }
