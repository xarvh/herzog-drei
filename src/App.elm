module App exposing (..)

import Browser.Events
import Config exposing (Config)
import Dict exposing (Dict)
import Game exposing (ValidatedMap)
import Gamepad exposing (Database, Gamepad)
import GamepadPort
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Input
import Json.Decode exposing (Decoder)
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
    | OnMenuNav Menu
    | OnMenuNavGamepads
    | OnOpenMapEditor
      --| OnMapEditorSave
      --| OnMapEditorLoad
      --| OnMapEditorPlay
    | OnStartGame ValidatedMap
    | OnQuit
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

        OnQuit ->
            let
                ( scene, seed ) =
                    demoScene model.seed
            in
            noCmd { model | scene = scene, seed = seed, maybeMenu = Nothing }

        OnImportString mapAsJson ->
            case model.maybeMenu of
                Just (MenuImportMap importModel) ->
                    updateOnImportString mapAsJson importModel model |> noCmd

                _ ->
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
    case ( keyName, model.maybeMenu ) of
        ( "Escape", Just MenuMain ) ->
            noCmd { model | maybeMenu = Nothing }

        ( "Escape", Just (MenuImportMap _) ) ->
            noCmd { model | maybeMenu = Just MenuMapSelection }

        ( "Escape", _ ) ->
            noCmd { model | maybeMenu = Just MenuMain }

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


isDemo : Model -> Bool
isDemo model =
    case model.scene of
        SceneMain SubSceneDemo _ ->
            True

        _ ->
            False


isPlaying : Model -> Bool
isPlaying model =
    case model.scene of
        SceneMain SubSceneGameplay _ ->
            True

        _ ->
            False


isMapEditor : Model -> Bool
isMapEditor model =
    case model.scene of
        SceneMapEditor _ ->
            True

        _ ->
            False


viewMenu : Menu -> Model -> Html Msg
viewMenu menu model =
    let
        when : Bool -> Html a -> Html a
        when condition stuff =
            if condition then
                stuff
            else
                text ""
    in
    div
        [ class "fullWindow bgOpaque flex alignCenter justifyCenter"
        ]
        [ div
            [ class "menu p2" ]
            [ case menu of
                MenuMain ->
                    div
                        []
                        [ when (isDemo model) <| pageButton "Play" (OnMenuNav MenuMapSelection)
                        , when (isDemo model) <| pageButton "Map Editor" OnOpenMapEditor

                        --, when (isPlaying model) <| pageButton "Resume" (OnKeyPress 27)
                        , when (isDemo model || isPlaying model) <| pageButton "Settings" (OnMenuNav MenuSettings)
                        , when (isDemo model || isPlaying model) <| pageButton "Gamepads" OnMenuNavGamepads

                        --, when (isMapEditor model) <| pageButton "Save" OnMapEditorSave
                        --, when (isMapEditor model) <| pageButton "Load" OnMapEditorLoad
                        --, when (isMapEditor model) <| pageButton "Play here" OnMapEditorPlay
                        , when (isPlaying model || isMapEditor model) <| pageButton "Quit" OnQuit
                        ]

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
                            [ button
                                [ { importString = ""
                                  , mapResult = Err ""
                                  }
                                    |> MenuImportMap
                                    |> OnMenuNav
                                    |> onClick
                                ]
                                [ text "Import..." ]
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


pageButton : String -> Msg -> Html Msg
pageButton label msg =
    button
        [ onClick msg ]
        [ text label ]


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
        , Browser.Events.onMouseDown (OnMouseButton True |> Json.Decode.succeed)
        , Browser.Events.onMouseUp (OnMouseButton False |> Json.Decode.succeed)
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
