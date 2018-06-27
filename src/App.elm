module App exposing (..)

import Browser.Events
import Config exposing (Config)
import Dict exposing (Dict)
import Game exposing (ValidatedMap)
import Gamepad exposing (Database, Gamepad)
import GamepadPort
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onFocus, onInput)
import Input
import Json.Decode exposing (Decoder)
import List.Extra
import LocalStoragePort
import MainScene
import Map
import MapEditor
import OfficialMaps
import Random
import Random.List
import Remap
import Set exposing (Set)
import Shell exposing (Shell, WindowSize)
import SplitScreen exposing (Viewport)
import Task


type alias Flags =
    Shell.Flags



-- Model


type Menu
    = MenuMain
    | MenuMapSelection
    | MenuImportMap ImportModel
    | MenuSettings
    | MenuGamepads Remap.Model


type alias ImportModel =
    { importString : String
    , mapResult : Result String ValidatedMap
    }


type SubScene
    = SubSceneDemo
    | SubSceneGameplay


type Scene
    = SceneMain SubScene MainScene.Model
    | SceneMapEditor MapEditor.Model


type alias Model =
    { scene : Scene
    , maybeMenu : Maybe Menu
    , selectedButtonName : String
    , seed : Random.Seed

    -- env stuff
    , flags : Flags
    , config : Config
    , params : Dict String String
    , windowSize : WindowSize
    , viewport : Viewport

    -- input stuff
    , mousePosition : { x : Int, y : Int }
    , mouseIsPressed : Bool
    , pressedKeys : Set String
    }


init : Dict String String -> Flags -> ( Model, Cmd Msg )
init params flags =
    let
        config =
            Config.fromString flags.config

        ( scene, seed ) =
            demoScene (Random.initialSeed flags.dateNow)

        windowSize =
            { width = flags.windowWidth
            , height = flags.windowHeight
            }
    in
    noCmd
        { scene = scene
        , maybeMenu = Just MenuMain
        , selectedButtonName = "Play"
        , seed = seed

        -- env stuff
        , flags = flags
        , config = config
        , params = params
        , windowSize = windowSize
        , viewport = makeViewport windowSize

        -- input stuff
        , mousePosition = { x = 0, y = 0 }
        , mouseIsPressed = False
        , pressedKeys = Set.empty
        }


demoScene : Random.Seed -> ( Scene, Random.Seed )
demoScene oldSeed =
    let
        mapGenerator : Random.Generator ValidatedMap
        mapGenerator =
            Random.List.choose OfficialMaps.maps
                |> Random.map (Tuple.first >> Maybe.withDefault OfficialMaps.default)

        ( map, newSeed ) =
            Random.step mapGenerator oldSeed
    in
    ( SceneMain SubSceneDemo (MainScene.initDemo newSeed map), newSeed )


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


makeViewport : WindowSize -> Viewport
makeViewport windowSize =
    SplitScreen.makeViewports windowSize 1
        |> List.head
        |> Maybe.withDefault SplitScreen.defaultViewport



-- Update


type Msg
    = Noop
      -- Menu buttons
    | OnMenuButton String
    | OnSelectButton String
    | OnStartGame ValidatedMap
      -- Map Import
    | OnImportString String
      -- TEA children
    | OnMainSceneMsg MainScene.Msg
    | OnMapEditorMsg MapEditor.Msg
    | OnRemapMsg Remap.Msg
      -- Env stuff used by map editor and main scene
    | OnWindowResizes Int Int
    | OnMouseButton Bool
    | OnMouseMoves Int Int
    | OnKeyDown String
    | OnKeyUp String
    | OnVisibilityChange Browser.Events.Visibility
      -- Config
    | OnToggleKeyboardAndMouse


noCmd : Model -> ( Model, Cmd Msg )
noCmd model =
    ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            noCmd model

        OnStartGame map ->
            { model
                | scene = SceneMain SubSceneGameplay <| MainScene.initTeamSelection model.seed map
                , maybeMenu = Nothing
            }
                |> noCmd

        OnImportString mapAsJson ->
            case model.maybeMenu of
                Just (MenuImportMap importModel) ->
                    updateOnImportString mapAsJson importModel model |> noCmd

                _ ->
                    noCmd model

        OnMenuButton buttonName ->
            updateOnButton buttonName model

        OnSelectButton name ->
            noCmd { model | selectedButtonName = name }

        -- Env stuff
        OnMouseButton state ->
            noCmd { model | mouseIsPressed = state }

        OnMouseMoves x y ->
            noCmd { model | mousePosition = { x = x, y = y } }

        OnWindowResizes w h ->
            let
                windowSize =
                    { width = w, height = h }
            in
            { model | windowSize = windowSize, viewport = makeViewport windowSize } |> noCmd

        OnKeyDown keyName ->
            noCmd { model | pressedKeys = Set.insert keyName model.pressedKeys }

        OnKeyUp keyName ->
            updateOnKeyUp keyName { model | pressedKeys = Set.remove keyName model.pressedKeys }

        OnVisibilityChange _ ->
            noCmd { model | pressedKeys = Set.empty }

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
            case ( model.scene, model.maybeMenu ) of
                ( SceneMapEditor mapEditor, Nothing ) ->
                    MapEditor.update mapEditorMsg (shell model) mapEditor
                        |> Tuple.mapFirst (\newMapEditor -> { model | scene = SceneMapEditor newMapEditor })
                        |> Tuple.mapSecond (Cmd.map OnMapEditorMsg)

                _ ->
                    noCmd model

        OnRemapMsg remapMsg ->
            case model.maybeMenu of
                Just (MenuGamepads remap) ->
                    Remap.update remapMsg remap |> updateOnRemap model

                _ ->
                    noCmd model

        -- Config
        OnToggleKeyboardAndMouse ->
            model |> updateConfig (\config -> { config | useKeyboardAndMouse = not config.useKeyboardAndMouse })


updateOnImportString : String -> ImportModel -> Model -> Model
updateOnImportString mapAsJson importModel model =
    { model
        | maybeMenu =
            { importModel
                | importString = mapAsJson
                , mapResult =
                    Map.fromString mapAsJson
                        |> Result.andThen Map.validate
            }
                |> MenuImportMap
                |> Just
    }


updateOnKeyUp : String -> Model -> ( Model, Cmd Msg )
updateOnKeyUp keyName model =
    case keyName of
        "ArrowUp" ->
            menuSelectPrevButton model |> noCmd

        "ArrowDown" ->
            menuSelectNextButton model |> noCmd

        -- back
        "Escape" ->
            menuBack model

        "Backspace" ->
            menuBack model

        "ArrowLeft" ->
            menuBack model

        -- "updateOnButton"
        "ArrowRight" ->
            updateOnButton model.selectedButtonName model

        "Enter" ->
            updateOnButton model.selectedButtonName model

        " " ->
            updateOnButton model.selectedButtonName model

        -- ignore
        _ ->
            let
                _ =
                    Debug.log "key" keyName
            in
            noCmd model



-- Menu


type alias MenuButton =
    { name : String
    , isVisible : Bool
    , update : Model -> ( Model, Cmd Msg )
    }


menuButtons : Model -> List MenuButton
menuButtons model =
    List.filter .isVisible <|
        case model.maybeMenu of
            Just MenuMain ->
                mainMenuButtons model

            _ ->
                []


mainMenuButtons : Model -> List MenuButton
mainMenuButtons model =
    let
        isDemo =
            case model.scene of
                SceneMain SubSceneDemo _ ->
                    True

                _ ->
                    False

        isPlaying =
            case model.scene of
                SceneMain SubSceneGameplay _ ->
                    True

                _ ->
                    False

        isFinished =
            False

        isMainMenu =
            model.maybeMenu == Just MenuMain
    in
    -- Game
    [ { name = "Play"
      , isVisible = isDemo
      , update = menuNav MenuMapSelection
      }
    , { name = "Play again"
      , isVisible = isPlaying && isFinished
      , update = menuNav MenuMapSelection
      }
    , { name = "Resume"
      , isVisible = isPlaying && not isFinished
      , update = menuBack
      }
    , { name = "How to play"
      , isVisible = True
      , update = menuBack
      }

    -- Map editor
    , { name = "Map Editor"
      , isVisible = isDemo
      , update = menuOpenMapEditor
      }

    -- Config
    , { name = "Settings"
      , isVisible = isDemo
      , update = menuNav MenuSettings
      }
    , { name = "Gamepads"
      , isVisible = isDemo
      , update = menuNav <| MenuGamepads <| Remap.init <| gamepadButtonMap
      }

    -- Back
    , { name = "Back"
      , isVisible = not isMainMenu
      , update = menuNav <| MenuGamepads <| Remap.init <| gamepadButtonMap
      }
    ]


menuNav : Menu -> Model -> ( Model, Cmd Msg )
menuNav menu model =
    noCmd { model | maybeMenu = Just menu }


menuOpenMapEditor : Model -> ( Model, Cmd Msg )
menuOpenMapEditor model =
    noCmd { model | maybeMenu = Nothing, scene = SceneMapEditor MapEditor.init }


menuDemo : Model -> ( Model, Cmd Msg )
menuDemo model =
    let
        ( scene, seed ) =
            demoScene model.seed
    in
    noCmd { model | scene = scene, seed = seed, maybeMenu = Nothing }


menuBack : Model -> ( Model, Cmd Msg )
menuBack model =
    case model.maybeMenu of
        Just MenuMain ->
            noCmd { model | maybeMenu = Nothing }

        Just (MenuImportMap _) ->
            noCmd { model | maybeMenu = Just MenuMapSelection }

        _ ->
            noCmd { model | maybeMenu = Just MenuMain }


updateOnButton : String -> Model -> ( Model, Cmd Msg )
updateOnButton buttonName model =
    case List.Extra.find (\button -> button.name == buttonName) (menuButtons model) of
        Nothing ->
            noCmd model

        Just button ->
            button.update model


selectButton : MenuButton -> Model -> Model
selectButton button model =
    { model | selectedButtonName = button.name }


menuSelectFirstButton : Model -> Model
menuSelectFirstButton model =
    case menuButtons model of
        [] ->
            model

        b :: bs ->
            selectButton b model


menuSelectLastButton : Model -> Model
menuSelectLastButton model =
    case menuButtons model |> List.reverse of
        [] ->
            model

        b :: bs ->
            selectButton b model


menuSelectNextButton : Model -> Model
menuSelectNextButton model =
    let
        maybeButton =
            menuButtons model
                |> List.Extra.dropWhile (\b -> b.name /= model.selectedButtonName)
                |> List.drop 1
                |> List.head
    in
    case maybeButton of
        Nothing ->
            menuSelectLastButton model

        Just button ->
            selectButton button model


menuSelectPrevButton : Model -> Model
menuSelectPrevButton model =
    let
        maybeButton =
            menuButtons model
                |> List.reverse
                |> List.Extra.dropWhile (\b -> b.name /= model.selectedButtonName)
                |> List.drop 1
                |> List.head
    in
    case maybeButton of
        Nothing ->
            menuSelectFirstButton model

        Just button ->
            selectButton button model



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


updateOnRemap : Model -> ( Remap.Model, Maybe (Database -> Database) ) -> ( Model, Cmd Msg )
updateOnRemap model ( remap, maybeUpdateDb ) =
    let
        updateDb =
            maybeUpdateDb |> Maybe.withDefault identity
    in
    { model | maybeMenu = Just (MenuGamepads remap) }
        |> updateConfig (\config -> { config | gamepadDatabase = updateDb model.config.gamepadDatabase })



-- Config


updateConfig : (Config -> Config) -> Model -> ( Model, Cmd a )
updateConfig updater model =
    let
        oldConfig =
            model.config

        newConfig =
            updater oldConfig

        cmd =
            if newConfig == oldConfig then
                Cmd.none
            else
                LocalStoragePort.set "config" (Config.toString newConfig)
    in
    ( { model | config = newConfig }, cmd )



-- View


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
                viewMenu menu model
        ]


viewMenu : Menu -> Model -> Html Msg
viewMenu menu model =
    div
        [ class "fullWindow bgOpaque flex alignCenter justifyCenter"
        ]
        [ div
            [ class "menu p2" ]
            [ case menu of
                MenuMain ->
                    menuButtons model
                        |> List.map (viewMenuButton model.selectedButtonName)
                        |> div [ class "flex flexColumn" ]

                MenuMapSelection ->
                    div
                        []
                        [ section
                            []
                            [ div [] [ text "Select map:" ]
                            , div []
                                [ OfficialMaps.maps
                                    |> List.map viewMapItem
                                    |> div []
                                ]
                            ]
                        , section
                            []
                            [{- button
                                [ { importString = ""
                                  , mapResult = Err ""
                                  }
                                    |> MenuImportMap
                                    |> OnMenuNav
                                    |> onClick
                                ]
                                [ text "Import..." ]
                             -}
                            ]
                        ]

                MenuImportMap { importString, mapResult } ->
                    section
                        []
                        [ label [] [ text "Import a map from JSON" ]
                        , div []
                            [ textarea
                                [ value importString
                                , onInput OnImportString
                                ]
                                []
                            ]
                        , case mapResult of
                            Err message ->
                                div
                                    [ class "red" ]
                                    [ text message ]

                            Ok map ->
                                button
                                    [ onClick (OnStartGame map) ]
                                    [ text "Play on this map" ]
                        ]

                MenuGamepads remap ->
                    section
                        []
                        [ Remap.view model.config.gamepadDatabase remap |> Html.map OnRemapMsg
                        ]

                MenuSettings ->
                    let
                        noGamepads =
                            False

                        --TODO Remap.gamepadsCount model.remap == 0
                        actuallyUseKeyboardAndMouse =
                            noGamepads || model.config.useKeyboardAndMouse

                        keyboardInstructionsClass =
                            if actuallyUseKeyboardAndMouse then
                                "gray"
                            else
                                "invisible"
                    in
                    div
                        []
                        [ section
                            [ class "flex" ]
                            [ input
                                [ type_ "checkbox"
                                , checked actuallyUseKeyboardAndMouse
                                , disabled noGamepads
                                , onClick OnToggleKeyboardAndMouse
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
                        ]
            ]
        ]


viewButton : Bool -> String -> Msg -> Html Msg
viewButton isSelected name msg =
    let
        borderColor =
            if isSelected then
                "black"
            else
                "transparent"
    in
    div
        [ class "menu-button"
        , style "border" ("3px solid " ++ borderColor)
        ]
        [ button
            [ onClick msg
            , onFocus (OnSelectButton name)
            ]
            [ text name ]
        ]


viewMenuButton : String -> MenuButton -> Html Msg
viewMenuButton selectedButtonName { name } =
    viewButton (name == selectedButtonName) name (OnMenuButton name)


viewMapItem : ValidatedMap -> Html Msg
viewMapItem map =
    div
        []
        [ button [ onClick (OnStartGame map) ] [ text map.name ]
        , span [] [ text <| " by " ++ map.author ]
        ]



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Browser.Events.onKeyDown (Input.keyboardDecoder OnKeyDown)
        , Browser.Events.onKeyUp (Input.keyboardDecoder OnKeyUp)
        , Browser.Events.onVisibilityChange OnVisibilityChange
        , Browser.Events.onMouseDown (OnMouseButton True |> Input.always)
        , Browser.Events.onMouseUp (OnMouseButton False |> Input.always)
        , Browser.Events.onMouseMove (Input.mouseMoveDecoder OnMouseMoves)
        , Browser.Events.onResize OnWindowResizes
        , case model.maybeMenu of
            Just (MenuGamepads remap) ->
                Remap.subscriptions GamepadPort.gamepad |> Sub.map OnRemapMsg

            _ ->
                Sub.none
        , case model.scene of
            SceneMain subScene scene ->
                MainScene.subscriptions scene |> Sub.map OnMainSceneMsg

            SceneMapEditor mapEditor ->
                MapEditor.subscriptions mapEditor |> Sub.map OnMapEditorMsg
        ]
