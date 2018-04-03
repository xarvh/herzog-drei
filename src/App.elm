module App exposing (..)

import AnimationFrame
import ColorPattern exposing (neutral)
import Dict exposing (Dict)
import Game
    exposing
        ( Base
        , Game
        , Id
        , Player
        , Projectile
        , Unit
        , clampToRadius
        , tile2Vec
        , vec2Tile
        )
import Game.Base
import Game.Player
import Game.Unit
import Game.Update
import Keyboard.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Mouse
import Random
import Set exposing (Set)
import Svg exposing (Svg)
import Svg.Attributes
import Svg.Events
import Time exposing (Time)
import View exposing (..)
import View.Gfx
import View.Mech
import View.Projectile
import View.Unit


--


gameToScreenRatio =
    10.0



--


type Msg
    = OnAnimationFrame Time
    | OnMouseButton Bool


type alias Model =
    { game : Game
    , mousePosition : Vec2
    , mouseIsPressed : Bool
    , time : Time
    }


init =
    let
        terrainObstacles =
            [ ( 0, 0 )
            , ( 1, 0 )
            , ( 2, 0 )
            , ( 3, 0 )
            , ( 3, 1 )
            , ( 4, 2 )
            ]

        ( game0, player1 ) =
            Random.initialSeed 0
                |> Game.init
                |> Game.addBase ( 0, 0 )
                |> Tuple.first
                |> Game.addPlayer (vec2 -3 -3)

        ( game1, player2 ) =
            game0
                |> Game.addPlayer (vec2 3 3)
    in
    game1
        |> Game.addStaticObstacles terrainObstacles
        |> Game.addUnit player1.id (vec2 0 -4)
        |> Tuple.first
        |> Game.addUnit player1.id (vec2 1 -4)
        |> Tuple.first
        |> Game.addUnit player1.id (vec2 2 -4)
        |> Tuple.first
        |> Game.addUnit player1.id (vec2 3 -4)
        |> Tuple.first
        |> Game.addUnit player2.id (vec2 0 4.8)
        |> Tuple.first
        |> Game.addUnit player2.id (vec2 -1 4.8)
        |> Tuple.first
        |> Game.addUnit player2.id (vec2 -2 4.8)
        |> Tuple.first
        |> Game.addUnit player2.id (vec2 -3 4.8)
        |> Tuple.first
        |> (\game ->
                { game = game
                , mousePosition = vec2 0 0
                , mouseIsPressed = False
                , time = 0
                }
           )
        |> noCmd



-- Update


noCmd : Model -> ( Model, Cmd a )
noCmd model =
    ( model, Cmd.none )


update : Vec2 -> List Keyboard.Extra.Key -> Msg -> Model -> ( Model, Cmd Msg )
update mousePosition pressedKeys msg model =
    case msg of
        OnMouseButton state ->
            noCmd { model | mouseIsPressed = state }

        OnAnimationFrame dtInMilliseconds ->
            let
                dt =
                    dtInMilliseconds / 1000

                { x, y } =
                    Keyboard.Extra.wasd pressedKeys

                isPressed key =
                    List.member key pressedKeys

                input =
                    { aim = Vec2.scale gameToScreenRatio mousePosition
                    , fire = model.mouseIsPressed
                    , transform = isPressed Keyboard.Extra.CharE
                    , switchUnit = isPressed Keyboard.Extra.Space

                    -- TODO this should be right mouse button
                    , rally = isPressed Keyboard.Extra.CharQ
                    , move = vec2 (toFloat x) (toFloat y)
                    }

                game =
                    Game.Update.update dt (Dict.singleton 2 input) model.game
            in
            noCmd
                { model
                    | game = game
                    , mousePosition = mousePosition
                    , time = model.time + dt
                }



-- View


checkersBackground : Float -> Svg Msg
checkersBackground size =
    let
        squareSize =
            1.0

        s =
            squareSize

        s2 =
            squareSize * 2
    in
    Svg.g
        []
        [ Svg.defs
            []
            [ Svg.pattern
                [ Svg.Attributes.id "grid"
                , width s2
                , height s2
                , Svg.Attributes.patternUnits "userSpaceOnUse"
                ]
                [ Svg.rect
                    [ x 0
                    , y 0
                    , width s
                    , height s
                    , fill "#eee"
                    ]
                    []
                , Svg.rect
                    [ x s
                    , y s
                    , width s
                    , height s
                    , fill "#eee"
                    ]
                    []
                ]
            ]
        , Svg.rect
            [ fill "url(#grid)"
            , x <| -size / 2
            , y <| -size / 2
            , width size
            , height size
            ]
            []
        ]


circle : Vec2 -> String -> Float -> Svg a
circle pos color size =
    Svg.circle
        [ cx <| Vec2.getX pos
        , cy <| Vec2.getY pos
        , r size
        , fill color
        ]
        []


square : Vec2 -> String -> Float -> Svg a
square pos color size =
    Svg.rect
        [ x <| Vec2.getX pos
        , y <| Vec2.getY pos
        , width size
        , height size
        , fill color
        ]
        []


viewBase : Game -> Base -> Svg Msg
viewBase game base =
    let
        colorPattern =
            Game.baseColorPattern game base

        color =
            if base.isActive then
                colorPattern.bright
            else
                colorPattern.dark

        v =
            Vec2.add (tile2Vec base.position) (vec2 -1 -1)
    in
    Svg.g
        []
        [ square v color 2

        --, square v "#00c" (toFloat base.containedUnits * 0.5)
        ]


viewUnit : Game -> Unit -> Svg Msg
viewUnit game unit =
    let
        colorPattern =
            Game.playerColorPattern game unit.ownerId
    in
    Svg.g
        [ transform [ translate unit.position ] ]
        [ View.Unit.unit unit.movementAngle unit.targetingAngle colorPattern.bright colorPattern.dark ]


viewPlayer : Game -> Player -> Svg a
viewPlayer game player =
    Svg.g
        [ transform [ translate player.position ] ]
        [ View.Mech.mech
            player.transformState
            player.headAngle
            player.topAngle
            player.colorPattern.bright
            player.colorPattern.dark
        ]


viewMarker : Game -> Player -> Svg a
viewMarker game player =
    circle player.markerPosition player.colorPattern.dark 0.2


viewProjectile : Projectile -> Svg a
viewProjectile projectile =
    View.Projectile.projectile projectile.position projectile.angle


view =
    gameView


testView : Model -> Svg a
testView model =
    let
        moveAngle =
            turns 0.1

        period =
            1

        wrap n p =
            n - (toFloat (floor (n / p)) * p)

        age =
            wrap model.time period

        start =
            View.Unit.gunOffset moveAngle

        end =
            model.mousePosition
                |> Vec2.scale 10
    in
    Svg.g
        [ transform [ "scale(0.4, 0.4)" ] ]
        [ View.Projectile.projectile (vec2 0 0) (pi / 6)

        --[ View.Mech.mech age (Game.vecToAngle model.mousePosition) 0 neutral.bright neutral.dark
        --[ View.Unit.unit (pi / 4) (Game.vecToAngle model.mousePosition) neutral.bright neutral.dark
        ]


gameView : Model -> Svg Msg
gameView { game } =
    Svg.g
        [ transform [ "scale(0.1, 0.1)" ] ]
        [ checkersBackground 10
        , game.staticObstacles
            |> Set.toList
            |> List.map (\pos -> square (tile2Vec pos) "gray" 1)
            |> Svg.g []
        , game.baseById
            |> Dict.values
            |> List.map (viewBase game)
            |> Svg.g []
        , game.unitById
            |> Dict.values
            |> List.map (viewUnit game)
            |> Svg.g []
        , game.playerById
            |> Dict.values
            |> List.map (viewPlayer game)
            |> Svg.g []
        , game.playerById
            |> Dict.values
            |> List.map (viewMarker game)
            |> Svg.g []
        , game.projectiles
            |> List.map viewProjectile
            |> Svg.g []
        , game.cosmetics
            |> List.map View.Gfx.render
            |> Svg.g []
        ]



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ AnimationFrame.diffs OnAnimationFrame
        , Mouse.downs (\_ -> OnMouseButton True)
        , Mouse.ups (\_ -> OnMouseButton False)
        ]
