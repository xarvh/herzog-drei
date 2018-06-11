module App exposing (..)

import Config exposing (Config)
import Dict exposing (Dict)
import Game exposing (ValidatedMap)
import Gamepad exposing (Gamepad)
import GamepadPort
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Keyboard
import Keyboard.Extra
import LocalStoragePort
import MainScene
import Map
import MapEditor
import Mouse
import Random
import Remap
import Set exposing (Set)
import Shell exposing (Shell)
import SplitScreen exposing (Viewport)
import Task
import Window


type alias Flags =
    Shell.Flags


{-| TODO actually load maps
-}
someMap : ValidatedMap
someMap =
    { halfWidth = 20
    , halfHeight = 10
    , leftBase = ( -15, 0 )
    , rightBase = ( 15, 0 )
    , smallBases = Set.fromList [ ( 0, -7 ), ( 0, 7 ) ]
    , wallTiles = Set.empty
    }



-- Model


type Menu
    = MenuMain
    | MenuMapSelection
    | MenuMapEditor
    | MenuSettings
    | MenuGamepads Remap.Model


type SubScene
    = SubSceneDemo
    | SubSceneGameplay


type Scene
    = SceneMain SubScene MainScene.Model
    | SceneMapEditor MapEditor.Model


type alias Model =
    { scene : Scene
    , maybeMenu : Maybe Menu
    , seed : Random.Seed

    -- env stuff
    , flags : Flags
    , config : Config
    , params : Dict String String
    , windowSize : Window.Size
    , viewport : Viewport

    -- input stuff
    , mousePosition : Mouse.Position
    , mouseIsPressed : Bool
    , pressedKeys : List Keyboard.Extra.Key
    }


init : Dict String String -> Flags -> ( Model, Cmd Msg )
init params flags =
    let
        config =
            Config.fromString flags.configAsString

        seed =
            Random.initialSeed flags.dateNow

        model =
            { scene = SceneMain SubSceneDemo (MainScene.initDemo seed someMap)
            , maybeMenu = Just MenuMain
            , seed = seed

            -- env stuff
            , flags = flags
            , config = config
            , params = params
            , windowSize = { width = 1, height = 1 }
            , viewport = SplitScreen.defaultViewport

            -- input stuff
            , mousePosition = { x = 0, y = 0 }
            , mouseIsPressed = False
            , pressedKeys = []
            }

        cmd =
            Window.size |> Task.perform OnWindowResizes
    in
    ( model, cmd )


shell : Model -> Shell
shell model =
    { mousePosition = model.mousePosition
    , mouseIsPressed = model.mouseIsPressed
    , windowSize = model.windowSize
    , viewport = model.viewport
    , params = model.params
    , pressedKeys = model.pressedKeys
    , config = model.config
    , flags = model.flags
    , gameIsPaused =
        case model.scene of
            SceneMain SubSceneDemo _ ->
                False

            _ ->
                model.maybeMenu /= Nothing
    }



-- Update


type Msg
    = Noop
      -- Menu navigation
    | OnMenuNav Menu
    | OnMenuNavGamepads
    | OnOpenMapEditor
    | OnStartGame
      -- TEA children
    | OnMainSceneMsg MainScene.Msg
    | OnMapEditorMsg MapEditor.Msg
      -- Env stuff used by map editor and main scene
    | OnWindowResizes Window.Size
    | OnMouseButton Bool
    | OnMouseMoves Mouse.Position
    | OnKeyboardMsg Keyboard.Extra.Msg
    | OnKeyPress Keyboard.KeyCode


noCmd : Model -> ( Model, Cmd Msg )
noCmd model =
    ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            noCmd model

        -- Menu navigation
        OnMenuNav menu ->
            noCmd { model | maybeMenu = Just menu }

        OnMenuNavGamepads ->
            noCmd { model | maybeMenu = Just <| MenuGamepads <| Remap.init <| gamepadButtonMap }

        OnOpenMapEditor ->
            noCmd
                { model
                    | maybeMenu = Nothing
                    , scene = SceneMapEditor MapEditor.init
                }

        OnStartGame ->
            { model
                | scene = SceneMain SubSceneGameplay <| MainScene.initTeamSelection model.seed someMap
                , maybeMenu = Nothing
            }
                |> noCmd

        -- Env stuff
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

        OnKeyPress keyCode ->
            case ( keyCode, model.maybeMenu ) of
                ( 27, Just MenuMain ) ->
                    noCmd { model | maybeMenu = Nothing }

                ( 27, _ ) ->
                    noCmd { model | maybeMenu = Just MenuMain }

                _ ->
                    noCmd model

        OnKeyboardMsg keyboardMsg ->
            noCmd { model | pressedKeys = Keyboard.Extra.update keyboardMsg model.pressedKeys }

        -- TEA children
        OnMainSceneMsg sceneMsg ->
            case model.scene of
                SceneMain subScene scene ->
                    MainScene.update sceneMsg (shell model) scene
                        |> Tuple.mapFirst (\newScene -> { model | scene = SceneMain subScene newScene })
                        |> Tuple.mapSecond (Cmd.map OnMainSceneMsg)

                _ ->
                    noCmd model

        OnMapEditorMsg mapEditorMsg ->
            case model.scene of
                SceneMapEditor mapEditor ->
                    MapEditor.update mapEditorMsg (shell model) mapEditor
                        |> Tuple.mapFirst (\newMapEditor -> { model | scene = SceneMapEditor newMapEditor })
                        |> Tuple.mapSecond (Cmd.map OnMapEditorMsg)

                _ ->
                    noCmd model



-- Gamepads


gamepadButtonMap =
    [ ( Gamepad.LeftLeft, "Move LEFT" )
    , ( Gamepad.LeftRight, "Move RIGHT" )
    , ( Gamepad.LeftUp, "Move UP" )
    , ( Gamepad.LeftDown, "Move DOWN" )

    --
    , ( Gamepad.RightLeft, "Aim LEFT" )
    , ( Gamepad.RightRight, "Aim RIGHT" )
    , ( Gamepad.RightUp, "Aim UP" )
    , ( Gamepad.RightDown, "Aim DOWN" )

    --
    , ( Gamepad.RightTrigger, "FIRE" )
    , ( Gamepad.RightBumper, "Alt FIRE" )
    , ( Gamepad.A, "Transform" )
    , ( Gamepad.B, "Rally" )
    ]



-- Config


saveConfig : Model -> Config -> Cmd a
saveConfig model config =
    LocalStoragePort.set model.flags.configKey (Config.toString config)



{-
   OnToggleKeyboardAndMouse ->
       ( model, Just <| OutcomeConfig { config | useKeyboardAndMouse = not config.useKeyboardAndMouse } )

   OnRemapMsg remapMsg ->
       Remap.update remapMsg model.remap
           |> Tuple.mapFirst (\newRemap -> { model | remap = newRemap })
           |> Tuple.mapSecond (Maybe.map <| \updateDb -> OutcomeConfig { config | gamepadDatabase = updateDb config.gamepadDatabase })

   OnMapString string ->
       case Map.fromString string |> Result.andThen Map.validate of
           Err message ->
               noCmd { model | errorMessage = message }

           Ok validatedMap ->
               ( { model | mapString = "", errorMessage = "Map loaded!" }, Just (OutcomeMap validatedMap) )

   OnOpenMapEditor ->
       ( model, Just OutcomeOpenMapEditor )
-}
-- View
{-
   viewConfig : Config -> Model -> Html Msg
   viewConfig config model =
       let
           noGamepads =
               Remap.gamepadsCount model.remap == 0

           actuallyUseKeyboardAndMouse =
               noGamepads || config.useKeyboardAndMouse

           keyboardInstructionsClass =
               if actuallyUseKeyboardAndMouse then
                   "gray"
               else
                   "invisible"
       in
       section
           [ class "flex" ]
           [ input
               [ type_ "checkbox"
               , checked actuallyUseKeyboardAndMouse
               , onClick OnToggleKeyboardAndMouse
               , disabled noGamepads
               ]
               []
           , div
               [ class "ml1" ]
               [ div
                   [ class "mb1" ]
                   [ text "Use Keyboard & Mouse" ]
               , [ "ASDW: Move"
                 , "Q: Move units"
                 , "E: Transform"
                 , "Click: Fire"
                 ]
                   |> List.map (\t -> div [] [ text t ])
                   |> div [ class keyboardInstructionsClass ]
               ]
           ]
-}


pageButton : String -> Msg -> Html Msg
pageButton label msg =
    button
        [ onClick msg ]
        [ text label ]


viewMenu : Model -> Html Msg
viewMenu model =
    div
        [ class "fullWindow flex alignCenter justifyCenter"
        ]
        [ div
            [ class "menu p2" ]
            [ case model.maybeMenu of
                Just MenuMain ->
                    div
                        []
                        [ pageButton "Play" OnStartGame --(OnMenuNav MenuMapSelection)
                        , pageButton "Map Editor" OnOpenMapEditor
                        , pageButton "Settings" (OnMenuNav MenuSettings)
                        , pageButton "Gamepads" OnMenuNavGamepads
                        ]

                Just MenuMapSelection ->
                    div
                        []
                        [ text "MapSelection!"
                        ]

                _ ->
                    text "TODO"
            ]
        ]


view : Model -> Html Msg
view model =
    div
        [ class "relative" ]
        [ case model.scene of
            SceneMain subScene scene ->
                MainScene.view (shell model) scene |> div []

            SceneMapEditor mapEditor ->
                MapEditor.view (shell model) mapEditor |> Html.map OnMapEditorMsg
        , case model.maybeMenu of
            Nothing ->
                text ""

            Just menu ->
                viewMenu model
        ]



{-

   case model.maybeMapEditor of
           Just mapEditor ->
               [ MapEditor.view mapEditor |> Html.map OnMapEditorMsg ]

           Nothing ->




-}
{-
               [ class "highlight-animation" ]
               [ text "Press Esc to toggle the Menu" ]
           , if not <| Remap.isRemapping model.remap then
               viewConfig config model
             else
               text ""
           , section
               []
               [ Remap.view config.gamepadDatabase model.remap |> Html.map OnRemapMsg
               ]
           , section
               []
               [ div [] [ text "Load map from JSON" ]
               , input
                   [ value model.mapString
                   , onInput OnMapString
                   ]
                   []
               , div [] [ text model.errorMessage ]
               , button [ onClick OnOpenMapEditor ] [ text "Open Map editor" ]
               ]
           ]
       ]
   ]
-}
-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Keyboard.ups OnKeyPress
        , Mouse.downs (\_ -> OnMouseButton True)
        , Mouse.ups (\_ -> OnMouseButton False)
        , Mouse.moves OnMouseMoves
        , Sub.map OnKeyboardMsg Keyboard.Extra.subscriptions
        , Window.resizes OnWindowResizes
        , case model.scene of
            SceneMain subScene scene ->
                MainScene.subscriptions scene |> Sub.map OnMainSceneMsg

            SceneMapEditor mapEditor ->
                MapEditor.subscriptions mapEditor |> Sub.map OnMapEditorMsg
        ]
