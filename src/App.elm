module App exposing (..)

import AnimationFrame
import Dict exposing (Dict)
import Game
    exposing
        ( Base
        , Game
        , Id
        , Player
        , Unit
        , clampToRadius
        , tile2Vec
        , vec2Tile
        )
import Game.Init
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
    Game


init =
    Random.initialSeed 0
        |> Game.Init.init
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

        OnAnimationFrame dt ->
            let
                { x, y } =
                    Keyboard.Extra.wasd pressedKeys

                movement =
                    vec2 (toFloat x) (toFloat y) |> clampToRadius 1
            in
            noCmd (Game.Update.update dt movement model)



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


viewBase : Base -> Svg Msg
viewBase base =
    let
        v =
            Vec2.add (tile2Vec base.position) (vec2 -1 -1)
    in
    Svg.g
        [ Svg.Events.onClick (OnBaseClick base.id) ]
        [ square v "purple" 2
        , square v "#00c" (toFloat base.containedUnits * 0.5)
        ]


viewUnit : Game -> Unit -> Svg Msg
viewUnit game unit =
    let
        ( x, y ) =
            Vec2.toTuple unit.position
    in
    Svg.g
        [ transform <| "translate(" ++ toString x ++ "," ++ toString y ++ ")" ]
        [ UnitSvg.unit "#0c0" "#393" ]


viewPlayer : Game -> Player -> Svg a
viewPlayer game player =
    circle player.position "green" 0.5


view : Model -> Svg Msg
view game =
    Svg.g
        [ transform "scale(0.1, 0.1)" ]
        [ checkersBackground 10
        , game.staticObstacles
            |> Set.toList
            |> List.map (\pos -> square (tile2Vec pos) "gray" 1)
            |> Svg.g []
        , game.baseById
            |> Dict.values
            |> List.map viewBase
            |> Svg.g []
        , game.unitById
            |> Dict.values
            |> List.map (viewUnit game)
            |> Svg.g []
        , game.playerById
            |> Dict.values
            |> List.map (viewPlayer game)
            |> Svg.g []
        ]



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ AnimationFrame.diffs OnAnimationFrame
        ]
