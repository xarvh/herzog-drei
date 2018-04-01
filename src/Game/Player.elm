module Game.Player exposing (..)

import ColorPattern exposing (ColorPattern)
import Dict exposing (Dict)
import Game
    exposing
        ( Delta(..)
        , Game
        , Id
        , Player
        , PlayerInput
        , TransformMode(..)
        , clampToRadius
        , tile2Vec
        , vec2Tile
        )
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Set exposing (Set)


-- globals


transformTime : Float
transformTime =
    0.2



--


transformMode : Player -> TransformMode
transformMode player =
    case player.transformingTo of
        Mech ->
            if player.transformState < 1 then
                Mech
            else
                Plane

        Plane ->
            if player.transformState > 0 then
                Plane
            else
                Mech



--


add : Vec2 -> Game -> ( Game, Player )
add position game =
    let
        id =
            game.lastId + 1

        colorPatternCount colorPattern =
            game.playerById
                |> Dict.values
                |> List.filter (\player -> player.colorPattern == colorPattern)
                |> List.length

        colorPattern =
            game.shuffledColorPatterns
                |> List.sortBy colorPatternCount
                |> List.head
                |> Maybe.withDefault ColorPattern.neutral

        startAngle =
            Vec2.negate position |> Game.vecToAngle

        player =
            { id = id
            , position = position
            , markerPosition = position
            , colorPattern = colorPattern
            , timeToReload = 0
            , headAngle = startAngle
            , topAngle = startAngle
            , transformState = 0
            , transformingTo = Mech
            }

        playerById =
            Dict.insert id player game.playerById
    in
    ( { game | playerById = playerById, lastId = id }, player )


think : Float -> Game -> PlayerInput -> Player -> List Delta
think dt game input player =
    let
        speed =
            case transformMode player of
                Mech ->
                    2.0

                Plane ->
                    6.0

        dx =
            input.move
                |> clampToRadius 1
                |> Vec2.scale (speed * dt)

        hasFreeGround p =
            Set.member (vec2Tile p.position) game.staticObstacles |> not

        transformingTo =
            if input.transform && hasFreeGround player then
                case player.transformingTo of
                    Plane ->
                        if player.transformState == 1 then
                            Mech
                        else
                            player.transformingTo

                    Mech ->
                        if player.transformState == 0 then
                            Plane
                        else
                            player.transformingTo
            else
                player.transformingTo

        transformDirection =
            case transformingTo of
                Mech ->
                    (-)

                Plane ->
                    (+)

        transform =
            DeltaPlayer player.id
                (\g p ->
                    { p
                        | transformingTo = transformingTo
                        , transformState = clamp 0 1 (transformDirection p.transformState (dt / transformTime))
                    }
                )

        moveTarget =
            if input.rally then
                [ DeltaPlayer player.id (\g p -> { p | markerPosition = player.position }) ]
            else
                []

        deltaMoveOrWalk =
            case transformMode player of
                Mech ->
                    deltaPlayerWalk

                Plane ->
                    deltaPlayerFly

        movePlayer =
            [ DeltaPlayer player.id (deltaMoveOrWalk dx) ]

        reload =
            if player.timeToReload > 0 then
                [ DeltaPlayer player.id (\g p -> { p | timeToReload = max 0 (p.timeToReload - dt) }) ]
            else
                []

        aimDirection =
            Vec2.sub input.aim player.position

        aimAngle =
            Game.vecToAngle aimDirection

        aim =
            [ DeltaPlayer player.id <|
                \g p ->
                    { p
                        | headAngle = Game.turnTo (5 * pi * dt) aimAngle p.headAngle
                        , topAngle = Game.turnTo (2 * pi * dt) aimAngle p.topAngle
                    }
            ]

        fire =
            if input.fire && player.timeToReload == 0 then
                [ DeltaPlayer player.id (\g p -> { p | timeToReload = 0.7 })
                , DeltaGame <|
                    Game.addLaser
                        { start = player.position
                        , end = Vec2.add player.position aimDirection
                        , age = 0
                        , colorPattern = player.colorPattern
                        }
                ]
            else
                []
    in
    List.concat
        [ moveTarget
        , movePlayer
        , reload
        , aim
        , fire
        , [ transform ]
        ]


deltaPlayerFly : Vec2 -> Game -> Player -> Player
deltaPlayerFly dp game player =
    { player | position = Vec2.add player.position dp }


deltaPlayerWalk : Vec2 -> Game -> Player -> Player
deltaPlayerWalk dp game player =
    let
        isObstacle tile =
            Set.member tile game.staticObstacles

        originalPosition =
            player.position

        originalTile =
            vec2Tile originalPosition

        idealPosition =
            Vec2.add originalPosition dp

        idealTile =
            vec2Tile idealPosition

        didNotChangeTile =
            idealTile == originalTile

        idealPositionIsObstacle =
            isObstacle idealTile
    in
    if didNotChangeTile || not idealPositionIsObstacle then
        { player | position = idealPosition }
    else
        let
            ( tX, tY ) =
                originalTile

            leftTile =
                ( tX - 1, tY )

            rightTile =
                ( tX + 1, tY )

            topTile =
                ( tX, tY + 1 )

            bottomTile =
                ( tX, tY - 1 )

            oX =
                toFloat tX

            oY =
                toFloat tY

            minX =
                if isObstacle leftTile then
                    oX
                else
                    oX - 1

            maxX =
                if isObstacle rightTile then
                    oX + 0.99
                else
                    oX + 1.99

            minY =
                if isObstacle bottomTile then
                    oY
                else
                    oY - 1

            maxY =
                if isObstacle topTile then
                    oY + 0.99
                else
                    oY + 1.99

            ( iX, iY ) =
                Vec2.toTuple idealPosition

            fX =
                clamp minX maxX iX

            fY =
                clamp minY maxY iY
        in
        { player | position = vec2 fX fY }
