module App exposing (..)

import AnimationFrame
import Bot.Dummy
import Dict exposing (Dict)
import Game exposing (..)
import Init
import Update
import Html exposing (Html, div)
import Html.Attributes exposing (class, style)
import Keyboard.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Mouse
import SplitScreen exposing (Viewport)
import Task
import Time exposing (Time)
import View.Background
import View.Game
import Window


type Msg
    = OnAnimationFrame Time
    | OnMouseButton Bool
    | OnMouseMoves Mouse.Position
    | OnWindowResizes Window.Size


type alias Model =
    { game : Game
    , botStatesByKey : Dict String Bot.Dummy.State
    , mousePosition : Mouse.Position
    , mouseIsPressed : Bool
    , windowSize : Window.Size
    , viewport : Viewport
    , fps : List Float
    , terrain : List View.Background.Rect
    , params : Dict String String
    }



-- input stuff


inputKeyboardAndMouseKey : String
inputKeyboardAndMouseKey =
    "keyboard+mouse"


inputGamepadKey : Int -> String
inputGamepadKey index =
    "gamepad " ++ toString index


inputKeyIsHuman : String -> Bool
inputKeyIsHuman key =
    inputIsBot key |> not



-- init


init : Dict String String -> ( Model, Cmd Msg )
init params =
    let
        game =
            Init.setupPhase { halfWidth = 20, halfHeight = 10 }
    in
    ( { game = game
      , botStatesByKey = Dict.empty
      , mousePosition = { x = 0, y = 0 }
      , mouseIsPressed = False
      , windowSize = { width = 1, height = 1 }
      , viewport = SplitScreen.defaultViewport
      , fps = []
      , params = params
      , terrain = View.Background.initRects game
      }
    , Window.size |> Task.perform OnWindowResizes
    )



-- Update


noCmd : Model -> ( Model, Cmd a )
noCmd model =
    ( model, Cmd.none )


addMissingBots : Model -> Model
addMissingBots model =
    if model.game.phase == PhaseSetup then
        model
    else
        let
            initBot : String -> Team -> Int -> Game -> Bot.Dummy.State
            initBot inputKey team n game =
                Bot.Dummy.init inputKey team.id (List.all inputIsBot team.players |> not) n game

            addBot : Team -> String -> Dict String Bot.Dummy.State -> Dict String Bot.Dummy.State
            addBot team inputKey botStatesByKey =
                Dict.insert
                    inputKey
                    (initBot inputKey team (Dict.size botStatesByKey) model.game)
                    botStatesByKey

            addTeamBots : Team -> Dict String Bot.Dummy.State -> Dict String Bot.Dummy.State
            addTeamBots team botStatesByKey =
                team.players
                    |> List.filter inputIsBot
                    |> List.filter (\input -> Dict.member input botStatesByKey |> not)
                    |> List.foldl (addBot team) botStatesByKey

            botStates =
                model.botStatesByKey
                    |> addTeamBots model.game.leftTeam
                    |> addTeamBots model.game.rightTeam
        in
        { model | botStatesByKey = botStates }


update : List Keyboard.Extra.Key -> Msg -> Model -> ( Model, Cmd Msg )
update pressedKeys msg model =
    case msg of
        OnMouseButton state ->
            noCmd { model | mouseIsPressed = state }

        OnMouseMoves mousePosition ->
            noCmd { model | mousePosition = mousePosition }

        OnWindowResizes windowSize ->
            { model
                | windowSize = windowSize
                , viewport =
                    SplitScreen.makeViewports windowSize 1
                        |> List.head
                        |> Maybe.withDefault SplitScreen.defaultViewport
            }
                |> noCmd

        OnAnimationFrame timeInMilliseconds ->
            let
                { x, y } =
                    Keyboard.Extra.wasd pressedKeys

                isPressed key =
                    List.member key pressedKeys

                mouseAim =
                    SplitScreen.mouseScreenToViewport model.mousePosition model.viewport
                        |> Vec2.fromTuple
                        |> Vec2.scale (View.Game.tilesToViewport model.game model.viewport)
                        |> AimRelative

                keyboardAndMouseInput =
                    { aim = mouseAim
                    , fire = model.mouseIsPressed
                    , transform = isPressed Keyboard.Extra.CharE
                    , switchUnit = isPressed Keyboard.Extra.Space

                    -- TODO this should be right mouse button
                    , rally = isPressed Keyboard.Extra.CharQ
                    , move = vec2 (toFloat x) (toFloat y)
                    }

                foldBot : String -> Bot.Dummy.State -> ( Dict String Bot.Dummy.State, Dict String InputState ) -> ( Dict String Bot.Dummy.State, Dict String InputState )
                foldBot inputSourceKey oldState ( statesByKey, inputsByKey ) =
                    let
                        ( newState, input ) =
                            Bot.Dummy.update model.game oldState
                    in
                    ( Dict.insert inputSourceKey newState statesByKey, Dict.insert inputSourceKey input inputsByKey )

                ( botStatesByKey, botInputsByKey ) =
                    Dict.foldl foldBot ( Dict.empty, Dict.empty ) model.botStatesByKey

                inputStatesByKey =
                    botInputsByKey
                        |> Dict.insert inputKeyboardAndMouseKey keyboardAndMouseInput

                -- All times in the game are in seconds
                time =
                    timeInMilliseconds / 1000

                dt =
                    time - model.game.time

                game =
                    Update.update time inputStatesByKey model.game
            in
            { model
                | game = game
                , botStatesByKey = botStatesByKey
                , fps = (1 / dt) :: List.take 20 model.fps
            }
                |> addMissingBots
                |> noCmd



-- Test View
{-
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
               wrap model.game.time period / 5
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
-}


view : Model -> Html Msg
view model =
    let
        fps =
            List.sum model.fps / toFloat (List.length model.fps) |> round

        viewport =
            SplitScreen.makeViewports model.windowSize 1
    in
    div
        []
        [ [ View.Game.view model.terrain model.viewport model.game ]
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
        [ AnimationFrame.times OnAnimationFrame
        , Mouse.downs (\_ -> OnMouseButton True)
        , Mouse.ups (\_ -> OnMouseButton False)
        , Mouse.moves OnMouseMoves
        , Window.resizes OnWindowResizes
        ]
