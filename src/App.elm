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
        , UnitType(..)
        , clampToRadius
        , tile2Vec
        , vec2Tile
        )
import Game.Update
import Html exposing (div)
import Html.Attributes exposing (class)
import Keyboard.Extra
import List.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Mouse
import PlayerThink
import Random
import Set exposing (Set)
import SplitScreen exposing (Viewport)
import Svg exposing (Svg)
import Svg.Attributes
import Svg.Events
import Task
import Time exposing (Time)
import View exposing (..)
import View.Gfx
import View.Mech
import View.Projectile
import View.Unit
import Window


--


type Msg
    = OnAnimationFrame Time
    | OnMouseButton Bool
    | OnMouseMoves Mouse.Position
    | OnWindowResizes Window.Size


type alias Model =
    { game : Game
    , mousePosition : Mouse.Position
    , mouseIsPressed : Bool
    , viewports : List Viewport
    , windowSize : Window.Size
    , time : Time
    }


init : ( Model, Cmd Msg )
init =
    let
        addPlayerAndMech : Vec2 -> Game -> ( Game, Player )
        addPlayerAndMech position game =
            let
                ( game_, player ) =
                    Game.addPlayer position game
            in
            ( game_
                |> Game.addUnit player.id True position
                |> Tuple.first
            , player
            )

        addAiUnit : Id -> Vec2 -> Game -> Game
        addAiUnit ownerId position game =
            Game.addUnit ownerId False position game |> Tuple.first

        terrainObstacles =
            [ ( 0, 0 )
            , ( 1, 0 )
            , ( 2, 0 )
            , ( 3, 0 )
            , ( 3, 1 )
            , ( 4, 2 )
            ]

        game =
            Random.initialSeed 0
                |> Game.init
                |> Game.addBase ( 0, 0 )
                |> Tuple.first

        ( game_, player1 ) =
            game |> addPlayerAndMech (vec2 -3 -3)

        ( game__, player2 ) =
            game_ |> addPlayerAndMech (vec2 3 3)
    in
    game__
        |> Game.addStaticObstacles terrainObstacles
        |> addAiUnit player1.id (vec2 0 -4)
        |> addAiUnit player1.id (vec2 1 -4)
        |> addAiUnit player1.id (vec2 2 -4)
        |> addAiUnit player1.id (vec2 3 -4)
        |> addAiUnit player2.id (vec2 0 4.8)
        |> addAiUnit player2.id (vec2 -1 4.8)
        |> addAiUnit player2.id (vec2 -2 4.8)
        |> addAiUnit player2.id (vec2 -3 4.8)
        |> (\game ->
                { game = game
                , mousePosition = { x = 0, y = 0 }
                , mouseIsPressed = False
                , viewports = []
                , windowSize = { width = 1, height = 1 }
                , time = 0
                }
           )
        |> flip (,) (Window.size |> Task.perform OnWindowResizes)



-- Update


noCmd : Model -> ( Model, Cmd a )
noCmd model =
    ( model, Cmd.none )


setViewports : Window.Size -> Model -> Model
setViewports windowSize model =
    { model
        | windowSize = windowSize
        , viewports = SplitScreen.makeViewports windowSize (Dict.size model.game.playerById)
    }


update : List Keyboard.Extra.Key -> Msg -> Model -> ( Model, Cmd Msg )
update pressedKeys msg model =
    case msg of
        OnMouseButton state ->
            noCmd { model | mouseIsPressed = state }

        OnMouseMoves mousePosition ->
            noCmd { model | mousePosition = mousePosition }

        OnWindowResizes windowSize ->
            setViewports windowSize model |> noCmd

        OnAnimationFrame dtInMilliseconds ->
            let
                -- All times in the game are in seconds
                -- Also, cap dt to 0.1 secs, in case the app goes in background
                dt =
                    dtInMilliseconds / 1000 |> min 0.1

                { x, y } =
                    Keyboard.Extra.wasd pressedKeys

                isPressed key =
                    List.member key pressedKeys

                ( mouseX, mouseY ) =
                    model.viewports
                        |> List.head
                        |> Maybe.map (SplitScreen.mouseScreenToViewport model.mousePosition)
                        |> Maybe.withDefault ( 0, 0 )

                input =
                    { aim = vec2 mouseX mouseY
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
    case unit.type_ of
        UnitTypeMech mechRecord ->
            Svg.g
                [ transform [ translate unit.position ] ]
                [ View.Mech.mech
                    mechRecord.transformState
                    unit.lookAngle
                    unit.fireAngle
                    colorPattern.bright
                    colorPattern.dark
                ]

        UnitTypeSub subRecord ->
            Svg.g
                [ transform [ translate unit.position ] ]
                [ View.Unit.unit
                    unit.lookAngle
                    unit.moveAngle
                    unit.fireAngle
                    colorPattern.bright
                    colorPattern.dark
                ]


viewMarker : Game -> Player -> Svg a
viewMarker game player =
    circle player.markerPosition player.colorPattern.dark 0.2


viewProjectile : Projectile -> Svg a
viewProjectile projectile =
    View.Projectile.projectile projectile.position projectile.angle



-- Test View


view =
    splitView


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
            vec2 0 0
    in
    Svg.g
        [ transform [ "scale(0.4, 0.4)" ] ]
        [ View.Projectile.projectile (vec2 0 0) (pi / 6)

        --[ View.Mech.mech age (Game.vecToAngle model.mousePosition) 0 neutral.bright neutral.dark
        --[ View.Unit.unit (pi / 4) (Game.vecToAngle model.mousePosition) neutral.bright neutral.dark
        ]



-- Game view


viewPlayer : Model -> ( Player, Viewport ) -> Svg Msg
viewPlayer { game } ( player, viewport ) =
    let
        units =
            Dict.values game.unitById

        mechPosition =
            PlayerThink.findMech player.id units
                |> Maybe.map (Tuple.first >> .position)
                |> Maybe.withDefault (vec2 0 0)

        offset =
            Vec2.negate mechPosition

        -- The scale should be enough to fit the mech's shooting range and then some
        viewportMinSizeInTiles =
            10

        isWithinViewport =
            SplitScreen.isWithinViewport viewport mechPosition viewportMinSizeInTiles
    in
    Svg.svg
        (SplitScreen.viewportToSvgAttributes viewport)
        [ Svg.g
            [ transform [ "scale(1 -1)", scale (1 / viewportMinSizeInTiles), translate offset ]
            ]
            [ checkersBackground 10
            , game.staticObstacles
                |> Set.toList
                |> List.filter (\pos -> isWithinViewport (tile2Vec pos) 1)
                |> List.map (\pos -> square (tile2Vec pos) "gray" 1)
                |> Svg.g []
            , game.baseById
                |> Dict.values
                |> List.filter (\b -> isWithinViewport (tile2Vec b.position) 3)
                |> List.map (viewBase game)
                |> Svg.g []
            , units
                |> List.filter (\u -> isWithinViewport u.position 1.5)
                |> List.map (viewUnit game)
                |> Svg.g []
            , viewMarker game player
            , game.projectileById
                |> Dict.values
                |> List.filter (\p -> isWithinViewport p.position 0.5)
                |> List.map viewProjectile
                |> Svg.g []
            , game.cosmetics
                -- TODO viewport cull
                |> List.map View.Gfx.render
                |> Svg.g []
            ]
        ]


splitView : Model -> Svg Msg
splitView model =
    let
        sortedPlayers =
            model.game.playerById
                |> Dict.values
                |> List.sortBy .id

        viewportsAndPlayers =
            List.map2 (,) sortedPlayers model.viewports
    in
    div
        []
        [ viewportsAndPlayers
            |> List.map (viewPlayer model)
            |> SplitScreen.viewportsWrapper
        ]



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ AnimationFrame.diffs OnAnimationFrame
        , Mouse.downs (\_ -> OnMouseButton True)
        , Mouse.ups (\_ -> OnMouseButton False)
        , Mouse.moves OnMouseMoves
        , Window.resizes OnWindowResizes
        ]
