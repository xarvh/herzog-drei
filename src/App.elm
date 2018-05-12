module App exposing (..)

import AnimationFrame
import Base
import Bot.Dummy
import ColorPattern exposing (neutral)
import Dict exposing (Dict)
import Game exposing (..)
import Game.Init
import Game.Update
import Html exposing (div)
import Html.Attributes exposing (class, style)
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
import View.Background
import View.Base
import View.Gfx
import View.Hud
import View.Mech
import View.Projectile
import View.Sub
import Window


type Msg
    = OnAnimationFrame Time
    | OnMouseButton Bool
    | OnMouseMoves Mouse.Position
    | OnWindowResizes Window.Size


type alias Model =
    { game : Game
    , botState : Bot.Dummy.State
    , mousePosition : Mouse.Position
    , mouseIsPressed : Bool
    , viewports : List Viewport
    , windowSize : Window.Size
    , time : Time
    , fps : List Float
    }


init : ( Model, Cmd Msg )
init =
    let
        game =
            Game.Init.basicGame

        botPlayerId =
            game.playerById
                |> Dict.values
                |> List.Extra.find (\p -> p.controller == ControllerBot)
                |> Maybe.map .id
                |> Maybe.withDefault 0


    in
    ( { game = game
      , botState = Bot.Dummy.init botPlayerId game
      , mousePosition = { x = 0, y = 0 }
      , mouseIsPressed = False
      , viewports = []
      , windowSize = { width = 1, height = 1 }
      , time = 0
      , fps = []
      }
    , Window.size |> Task.perform OnWindowResizes
    )



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

                keyboardAndMouseInput =
                    { aim = vec2 mouseX mouseY
                    , fire = model.mouseIsPressed
                    , transform = isPressed Keyboard.Extra.CharE
                    , switchUnit = isPressed Keyboard.Extra.Space

                    -- TODO this should be right mouse button
                    , rally = isPressed Keyboard.Extra.CharQ
                    , move = vec2 (toFloat x) (toFloat y)
                    }

                ( botState, botInput ) =
                    Bot.Dummy.update model.game model.botState

                controllersAndInputs =
                    [ ( ControllerPlayer, keyboardAndMouseInput )
                    , ( ControllerBot, botInput )
                    ]

                game =
                    Game.Update.update dt controllersAndInputs model.game
            in
            noCmd
                { model
                    | game = game
                    , botState = botState
                    , time = model.time + dt
                    , fps = (1 / dt) :: List.take 20 model.fps
                }



-- View


checkersBackground : Game -> Svg Msg
checkersBackground game =
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
            , x (toFloat -game.halfWidth)
            , y (toFloat -game.halfHeight)
            , width (toFloat <| game.halfWidth * 2)
            , height (toFloat <| game.halfHeight * 2)
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


viewBase : Game -> Base -> Svg Msg
viewBase game base =
    let
        colorPattern =
            Base.colorPattern game base

        ( completion, target ) =
            case base.maybeOccupied of
                Nothing ->
                    ( 0, Game.BuildSub )

                Just occupied ->
                    ( occupied.buildCompletion, occupied.buildTarget )
    in
    Svg.g
        [ transform [ translate base.position ] ]
        [ case base.type_ of
            Game.BaseSmall ->
                View.Base.small completion colorPattern.bright colorPattern.dark

            Game.BaseMain ->
                View.Base.main_ completion colorPattern.bright colorPattern.dark
        , if target /= Game.BuildMech then
            Svg.text ""
          else
            Svg.g
                [ 0.9
                    * completion
                    + 0.1
                    * sin (pi * completion * 10)
                    |> toString
                    |> Svg.Attributes.opacity
                ]
                [ View.Mech.mech 1 0 0 neutral.dark colorPattern.dark ]
        ]


viewMech : Game -> ( Unit, MechComponent ) -> Svg a
viewMech game ( unit, mechRecord ) =
    let
        colorPattern =
            Game.playerColorPattern game unit.ownerId
    in
    Svg.g
        [ transform [ translate unit.position ] ]
        [ View.Mech.mech
            mechRecord.transformState
            unit.lookAngle
            unit.fireAngle
            colorPattern.bright
            colorPattern.dark

        --, View.Mech.collider mechRecord.transformState unit.fireAngle (vec2 0 0) |> View.renderCollider
        ]


viewSub : Game -> ( Unit, SubComponent ) -> Svg a
viewSub game ( unit, subRecord ) =
    let
        colorPattern =
            Game.playerColorPattern game unit.ownerId
    in
    Svg.g
        [ transform [ translate unit.position ] ]
        [ View.Sub.sub
            unit.lookAngle
            unit.moveAngle
            unit.fireAngle
            colorPattern.bright
            colorPattern.dark

        --, View.Sub.collider unit.moveAngle (vec2 0 0) |> View.renderCollider
        ]


mechVsUnit : List Unit -> ( List ( Unit, MechComponent ), List ( Unit, SubComponent ) )
mechVsUnit units =
    let
        folder unit ( mechs, subs ) =
            case unit.component of
                UnitMech mechRecord ->
                    ( ( unit, mechRecord ) :: mechs, subs )

                UnitSub subRecord ->
                    ( mechs, ( unit, subRecord ) :: subs )
    in
    List.foldl folder ( [], [] ) units


viewMarker : Game -> Player -> Svg a
viewMarker game player =
    circle player.markerPosition player.colorPattern.dark 0.2


viewProjectile : Projectile -> Svg a
viewProjectile projectile =
    View.Projectile.projectile projectile.position projectile.angle


viewHealthbar : Unit -> Svg a
viewHealthbar unit =
    if unit.integrity > 0.95 then
        Svg.text ""
    else
        View.Hud.healthBar unit.position unit.integrity


viewWall : Tile2 -> Svg a
viewWall ( xi, yi ) =
    let
        xf =
            toFloat xi

        yf =
            toFloat yi

        c =
            sin (xf * 9982399) + sin (yf * 17324650)

        d =
            sin (xf * 1372347) + sin (yf * 98325987)

        rot =
            5 * c

        color =
            (1 + d) / 4 * 255 |> floor |> toString
    in
    Svg.rect
        [ transform [ translate2 (xf + 0.5) (yf + 0.5), rotateDeg rot ]
        , x -0.55
        , y -0.55
        , width 1.1
        , height 1.1
        , fill <| "rgb(" ++ color ++ "," ++ color ++ "," ++ color ++ ")"
        ]
        []



-- Test View


view =
    splitView


testView : Model -> Svg a
testView model =
    let
        moveAngle =
            turns 0.1

        period =
            5

        wrap n p =
            n - (toFloat (floor (n / p)) * p)

        age =
            wrap model.time period / 5
    in
    Svg.svg
        [ Svg.Attributes.viewBox "-1 -1 2 2"
        , Svg.Attributes.width "100vh"
        , Svg.Attributes.height "100vh"
        ]
        [ Svg.g
            [ transform [ "scale(0.1, -0.1)" ]
            ]
            [ View.Base.main_ age neutral.bright neutral.dark

            --[ View.Mech.mech age (Game.vecToAngle model.mousePosition) 0 neutral.bright neutral.dark
            --[ View.Sub.sub (pi / 4) (Game.vecToAngle model.mousePosition) neutral.bright neutral.dark
            ]
        ]



--


viewVictory : Game -> Player -> Svg a
viewVictory game player =
    case game.maybeWinnerId of
        Nothing ->
            Svg.g [] []

        Just winnerId ->
            let
                ( text, pattern ) =
                    if player.id == winnerId then
                        ( "Victory!", player.colorPattern )
                    else
                        ( "Defeat!", neutral )
            in
            Svg.text_
                [ Svg.Attributes.textAnchor "middle"
                , Svg.Attributes.fontSize "0.2"
                , Svg.Attributes.fontFamily "'proxima-nova', sans-serif"
                , Svg.Attributes.fontWeight "700"
                , Svg.Attributes.fill pattern.bright
                , Svg.Attributes.stroke pattern.dark
                , Svg.Attributes.strokeWidth "0.005"
                , Svg.Attributes.y "-0.2"
                , Svg.Attributes.style "user-select: none;"
                ]
                [ Svg.text text ]



-- Game view


viewPlayer : Model -> ( Player, Viewport ) -> Svg Msg
viewPlayer model ( player, viewport ) =
    let
        game =
            model.game

        units =
            game.unitById |> Dict.values

        ( mechs, subs ) =
            mechVsUnit units

        offset =
            Vec2.negate player.viewportPosition

        -- The scale should be enough to fit the mech's shooting range and then some
        viewportMinSizeInTiles =
            20

        isWithinViewport =
            SplitScreen.isWithinViewport viewport player.viewportPosition viewportMinSizeInTiles
    in
    Svg.svg
        (SplitScreen.viewportToSvgAttributes viewport)
        [ Svg.g
            [ transform [ "scale(1 -1)", scale (1 / viewportMinSizeInTiles), translate offset ]
            ]
            --[ View.Background.terrain (model.time / 1000)
            [ checkersBackground model.game
            , subs
                |> List.filter (\( u, s ) -> s.mode == UnitModeFree && isWithinViewport u.position 0.7)
                |> List.map (viewSub game)
                |> Svg.g []
            , game.wallTiles
                |> Set.toList
                |> List.filter (\pos -> isWithinViewport (tile2Vec pos) 1)
                |> List.map viewWall
                |> Svg.g []
            , game.baseById
                |> Dict.values
                |> List.filter (\b -> isWithinViewport b.position 3)
                |> List.map (viewBase game)
                |> Svg.g []
            , subs
                |> List.filter (\( u, s ) -> s.mode /= UnitModeFree && isWithinViewport u.position 0.7)
                |> List.map (viewSub game)
                |> Svg.g []
            , mechs
                |> List.filter (\( u, m ) -> isWithinViewport u.position 1.5)
                |> List.map (viewMech game)
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
            , units
                |> List.filter (\u -> u.ownerId == player.id)
                |> List.map viewHealthbar
                |> Svg.g []
            ]
        , viewVictory game player
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

        fps =
            List.sum model.fps / toFloat (List.length model.fps) |> round
    in
    div
        []
        [ viewportsAndPlayers
            |> List.map (viewPlayer model)
            |> SplitScreen.viewportsWrapper
        , [ "FPS " ++ toString fps
          , "ASDW: Move"
          , "Q: Move units"
          , "E: Transform"
          , "Click: Fire"
          ]
            |> List.map (\t -> div [] [ Html.text t ])
            |> div [ style [ ( "position", "absolute" ), ( "top", "0" ) ] ]
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
