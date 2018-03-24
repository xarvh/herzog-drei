module App exposing (..)

import AnimationFrame
import ColorPattern exposing (neutral)
import Dict exposing (Dict)
import Game
    exposing
        ( Base
        , Game
        , Id
        , Laser
        , Player
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
import Svg.Attributes exposing (..)
import Svg.Events
import Time exposing (Time)
import UnitSvg


type Msg
    = OnAnimationFrame Time
    | OnTerrainClick
    | OnUnitClick Id
    | OnBaseClick Id


type alias Model =
    { game : Game
    , mousePosition : Vec2
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
                |> Game.Base.add ( 0, 0 )
                |> Tuple.first
                |> Game.Player.add (vec2 -3 -3)

        ( game1, player2 ) =
            game0
                |> Game.Player.add (vec2 3 3)
    in
    game1
        |> Game.addStaticObstacles terrainObstacles
        |> Game.Unit.add player1.id (vec2 0 -4)
        |> Tuple.first
        |> Game.Unit.add player1.id (vec2 1 -4)
        |> Tuple.first
        |> Game.Unit.add player1.id (vec2 2 -4)
        |> Tuple.first
        |> Game.Unit.add player1.id (vec2 3 -4)
        |> Tuple.first
        |> Game.Unit.add player2.id (vec2 0 4.8)
        |> Tuple.first
        |> Game.Unit.add player2.id (vec2 -1 4.8)
        |> Tuple.first
        |> Game.Unit.add player2.id (vec2 -2 4.8)
        |> Tuple.first
        |> Game.Unit.add player2.id (vec2 -3 4.8)
        |> Tuple.first
        |> (\g -> Model g (vec2 0 0) 0)
        |> noCmd



-- Update


noCmd : Model -> ( Model, Cmd a )
noCmd model =
    ( model, Cmd.none )


update : Vec2 -> List Keyboard.Extra.Key -> Msg -> Model -> ( Model, Cmd Msg )
update mousePosition pressedKeys msg model =
    case msg of
        OnTerrainClick ->
            noCmd model

        OnUnitClick unitId ->
            noCmd model

        OnBaseClick baseId ->
            noCmd model

        OnAnimationFrame dtInMilliseconds ->
            let
                dt =
                    dtInMilliseconds / 1000

                { x, y } =
                    Keyboard.Extra.wasd pressedKeys

                isSpace =
                    List.member Keyboard.Extra.Space pressedKeys

                input =
                    { move = vec2 (toFloat x) (toFloat y)
                    , fire = isSpace
                    }

                game =
                    Game.Update.update dt (Dict.singleton 2 input) model.game
            in
            noCmd
                { game = game
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
            toString squareSize

        s2 =
            toString (squareSize * 2)
    in
    Svg.g
        [ Svg.Events.onClick OnTerrainClick ]
        [ Svg.defs
            []
            [ Svg.pattern
                [ id "grid"
                , width s2
                , height s2
                , patternUnits "userSpaceOnUse"
                ]
                [ Svg.rect
                    [ x "0"
                    , y "0"
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
            , x <| toString <| -size / 2
            , y <| toString <| -size / 2
            , width <| toString size
            , height <| toString size
            ]
            []
        ]


circle : Vec2 -> String -> Float -> Svg a
circle pos color size =
    Svg.circle
        [ Vec2.getX pos |> toString |> cx
        , Vec2.getY pos |> toString |> cy
        , size |> toString |> r
        , fill color
        ]
        []


square : Vec2 -> String -> Float -> Svg a
square pos color size =
    Svg.rect
        [ Vec2.getX pos |> toString |> x
        , Vec2.getY pos |> toString |> y
        , size |> toString |> width
        , size |> toString |> height
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
        [ Svg.Events.onClick (OnBaseClick base.id) ]
        [ square v color 2

        --, square v "#00c" (toFloat base.containedUnits * 0.5)
        ]


viewUnit : Game -> Unit -> Svg Msg
viewUnit game unit =
    let
        colorPattern =
            Game.playerColorPattern game unit.ownerId

        ( x, y ) =
            Vec2.toTuple unit.position
    in
    Svg.g
        [ transform <| "translate(" ++ toString x ++ "," ++ toString y ++ ")" ]
        [ UnitSvg.unit unit.movementAngle unit.targetingAngle colorPattern.bright colorPattern.dark ]


viewPlayer : Game -> Player -> Svg a
viewPlayer game player =
    circle player.position player.colorPattern.bright 0.5


viewMarker : Game -> Player -> Svg a
viewMarker game player =
    circle player.markerPosition player.colorPattern.dark 0.2


viewLaser : Laser -> Svg a
viewLaser laser =
    UnitSvg.laser laser.start laser.end laser.colorPattern.bright laser.age


view =
    gameView


testView : Model -> Svg a
testView model =
    let
        moveAngle =
            turns 0.1

        period =
            UnitSvg.laserLifeSpan

        wrap n p =
            n - (toFloat (floor (n / p)) * p)

        age =
            wrap model.time period

        start =
            UnitSvg.gunOffset moveAngle

        end =
            model.mousePosition
                |> Vec2.scale 10
    in
    Svg.g
        [ transform "scale(0.1, 0.1)" ]
        [ UnitSvg.unit moveAngle (Game.vecToAngle model.mousePosition) neutral.bright neutral.dark
        , UnitSvg.laser start end neutral.bright age
        ]


gameView : Model -> Svg Msg
gameView { game } =
    Svg.g
        [ transform "scale(0.1, 0.1)" ]
        [ checkersBackground 10
        , game.staticObstacles
            |> Set.toList
            |> List.map (\pos -> square (tile2Vec pos) "gray" 1)
            |> Svg.g []
        , game.baseById
            |> Dict.values
            |> List.map (viewBase game)
            |> Svg.g []
        , game.lasers
            |> List.map viewLaser
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
        ]



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ AnimationFrame.diffs OnAnimationFrame
        ]
