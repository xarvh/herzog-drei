module App exposing (..)

import Bot.Dummy
import Config exposing (Config)
import Dict exposing (Dict)
import Game exposing (..)
import Gamepad exposing (Gamepad)
import GamepadPort
import Html exposing (..)
import Html.Attributes exposing (class, style)
import Init
import Keyboard
import Keyboard.Extra
import LocalStoragePort
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Menu
import Mouse
import SplitScreen exposing (Viewport)
import Task
import Time exposing (Time)
import Update
import View.Background
import View.Game
import Window


type alias Flags =
    { configAsString : String
    , configKey : String
    , dateNow : Int
    }


type Msg
    = Noop
    | OnGamepad ( Time, Gamepad.Blob )
    | OnMouseButton Bool
    | OnMouseMoves Mouse.Position
    | OnKeyboardMsg Keyboard.Extra.Msg
    | OnWindowResizes Window.Size
    | OnMenuMsg Menu.Msg
    | OnKeyPress Keyboard.KeyCode


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
    , pressedKeys : List Keyboard.Extra.Key
    , maybeMenu : Maybe Menu.Model
    , config : Config
    , flags : Flags
    }



-- init


init : Dict String String -> Flags -> ( Model, Cmd Msg )
init params flags =
    let
        game =
            Init.setupPhase flags.dateNow { halfWidth = 20, halfHeight = 10 }

        config =
            Config.fromString flags.configAsString

        maybeMenu =
            if Dict.member "noMenu" params then
                Nothing
            else
                Just (Menu.init config)
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
      , pressedKeys = []
      , maybeMenu = maybeMenu
      , config = config
      , flags = flags
      }
    , Window.size |> Task.perform OnWindowResizes
    )



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



-- gamepad database


saveConfig : Model -> Config -> Cmd a
saveConfig model config =
    LocalStoragePort.set model.flags.configKey (Config.toString config)



-- Input: Bots


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



-- Input: Gamepads


threshold : Vec2 -> Vec2
threshold v =
    if Vec2.length v > 0.1 then
        v
    else
        vec2 0 0


gamepadToInput : Gamepad -> ( String, InputState )
gamepadToInput gamepad =
    ( "gamepad " ++ toString (Gamepad.getIndex gamepad)
    , { aim = vec2 (Gamepad.rightX gamepad) (Gamepad.rightY gamepad) |> threshold |> AimAbsolute
      , fire =
            Gamepad.rightBumperIsPressed gamepad
                || Gamepad.rightTriggerIsPressed gamepad
                || Gamepad.rightStickIsPressed gamepad
      , transform = Gamepad.aIsPressed gamepad
      , switchUnit = False
      , rally = Gamepad.bIsPressed gamepad
      , move = vec2 (Gamepad.leftX gamepad) (Gamepad.leftY gamepad) |> threshold
      }
    )


allBotsThink : Model -> ( Dict String Bot.Dummy.State, Dict String InputState )
allBotsThink model =
    let
        foldBot : String -> Bot.Dummy.State -> ( Dict String Bot.Dummy.State, Dict String InputState ) -> ( Dict String Bot.Dummy.State, Dict String InputState )
        foldBot inputSourceKey oldState ( statesByKey, inputsByKey ) =
            let
                ( newState, input ) =
                    Bot.Dummy.update model.game oldState
            in
            ( Dict.insert inputSourceKey newState statesByKey, Dict.insert inputSourceKey input inputsByKey )
    in
    Dict.foldl foldBot ( Dict.empty, Dict.empty ) model.botStatesByKey



-- Input: Keyboard & Mouse


getKeyboardAndMouseInputState : Model -> InputState
getKeyboardAndMouseInputState model =
    let
        { x, y } =
            Keyboard.Extra.wasd model.pressedKeys

        isPressed key =
            List.member key model.pressedKeys

        mouseAim =
            SplitScreen.mouseScreenToViewport model.mousePosition model.viewport
                |> Vec2.fromTuple
                |> Vec2.scale (View.Game.tilesToViewport model.game model.viewport)
                |> AimRelative
    in
    { aim = mouseAim
    , fire = model.mouseIsPressed
    , transform = isPressed Keyboard.Extra.CharE
    , switchUnit = isPressed Keyboard.Extra.Space

    -- TODO this should be right mouse button
    , rally = isPressed Keyboard.Extra.CharQ
    , move = vec2 (toFloat x) (toFloat y)
    }



-- Update


noCmd : Model -> ( Model, Cmd a )
noCmd model =
    ( model, Cmd.none )


updateOnGamepad : ( Time, Gamepad.Blob ) -> Model -> ( Model, Cmd Msg )
updateOnGamepad ( timeInMilliseconds, gamepadBlob ) model =
    let
        gamepadsInputByKey =
            gamepadBlob
                |> Gamepad.getGamepads model.config.gamepadDatabase
                |> List.map gamepadToInput
                |> Dict.fromList

        keyAndMouse =
            if model.config.useKeyboardAndMouse || Dict.size gamepadsInputByKey == 0 then
                Dict.singleton inputKeyboardAndMouseKey (getKeyboardAndMouseInputState model)
            else
                Dict.empty

        ( botStatesByKey, botInputsByKey ) =
            allBotsThink model

        inputStatesByKey =
            botInputsByKey
                |> Dict.union gamepadsInputByKey
                |> Dict.union keyAndMouse

        -- All times in the game are in seconds
        time =
            timeInMilliseconds / 1000

        dt =
            time - model.game.time

        game =
            if model.maybeMenu == Nothing then
                Update.update time inputStatesByKey model.game
            else
                model.game
    in
    { model
        | game = game
        , botStatesByKey = botStatesByKey
        , fps = (1 / dt) :: List.take 20 model.fps
    }
        |> addMissingBots
        |> noCmd


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            noCmd model

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

        OnMenuMsg menuMsg ->
            case model.maybeMenu of
                Nothing ->
                    noCmd model

                Just menu ->
                    case Menu.update menuMsg model.config menu of
                        ( menu, Nothing ) ->
                            noCmd { model | maybeMenu = Just menu }

                        ( menu, Just config ) ->
                            ( { model | maybeMenu = Just menu, config = config }
                            , saveConfig model config
                            )

        OnKeyboardMsg keyboardMsg ->
            noCmd { model | pressedKeys = Keyboard.Extra.update keyboardMsg model.pressedKeys }

        OnGamepad timeAndGamepadBlob ->
            updateOnGamepad timeAndGamepadBlob model

        OnKeyPress keyCode ->
            case keyCode of
                27 ->
                    noCmd
                        { model
                            | maybeMenu =
                                if model.maybeMenu == Nothing then
                                    Just (Menu.init model.config)
                                else
                                    Nothing
                        }

                _ ->
                    noCmd model


view : Model -> Html Msg
view model =
    let
        fps =
            List.sum model.fps / toFloat (List.length model.fps) |> round

        viewport =
            SplitScreen.makeViewports model.windowSize 1
    in
    div
        [ class "relative" ]
        [ div
            [ class "game-area" ]
            [ [ View.Game.view model.terrain model.viewport model.game ]
                |> SplitScreen.viewportsWrapper
            , if Dict.member "fps" model.params then
                div
                    [ style [ ( "position", "absolute" ), ( "top", "0" ) ] ]
                    [ text ("FPS " ++ toString fps) ]
              else
                text ""
            ]
        , case model.maybeMenu of
            Just menu ->
                Menu.view model.config menu |> Html.map OnMenuMsg

            Nothing ->
                text ""
        ]



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ GamepadPort.gamepad OnGamepad
        , Mouse.downs (\_ -> OnMouseButton True)
        , Mouse.ups (\_ -> OnMouseButton False)
        , Mouse.moves OnMouseMoves
        , Sub.map OnKeyboardMsg Keyboard.Extra.subscriptions
        , Window.resizes OnWindowResizes
        , Keyboard.ups OnKeyPress
        , case model.maybeMenu of
            Nothing ->
                Sub.none

            Just menu ->
                Menu.subscriptions menu |> Sub.map OnMenuMsg
        ]
