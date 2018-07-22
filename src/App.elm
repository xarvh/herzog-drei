module App exposing (..)

import Browser.Events
import Config exposing (Config)
import Dict exposing (Dict)
import Game exposing (ValidatedMap)
import Gamepad exposing (Gamepad, UserMappings)
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
import Set exposing (Set)
import Shell exposing (Shell, WindowSize)
import SplitScreen exposing (Viewport)
import Task
import View.Game


type alias Flags =
    Shell.Flags



-- Model


type Menu
    = MenuMain
    | MenuMapSelection
    | MenuImportMap ImportModel
    | MenuHowToPlay
    | MenuSettings
    | MenuGamepads Gamepad.RemapModel


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
    , selectedButton : SelectedButton
    , seed : Random.Seed

    -- env stuff
    , flags : Flags
    , config : Config
    , windowSize : WindowSize
    , viewport : Viewport

    -- input stuff
    , mousePosition : { x : Int, y : Int }
    , mouseIsPressed : Bool
    , pressedKeys : Set String
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
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
        , selectedButton = SelectedButton ""
        , seed = seed

        -- env stuff
        , flags = flags
        , config = config
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
    | OnGamepad Gamepad.Blob
      -- Menu buttons
    | OnStartGame ValidatedMap
    | OnMenuButton String
    | OnSelectButton String
    | OnImportString String
      -- TEA children
    | OnMapEditorMsg MapEditor.Msg
    | OnRemapMsg Gamepad.RemapMsg
      -- Env stuff used by map editor and main scene
    | OnWindowResizes Int Int
    | OnMouseButton Bool
    | OnMouseMoves Int Int
    | OnKeyDown String
    | OnKeyUp String
    | OnVisibilityChange Browser.Events.Visibility


noCmd : Model -> ( Model, Cmd a )
noCmd model =
    ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            noCmd model

        OnGamepad blob ->
            updateOnGamepad blob model

        OnStartGame map ->
            updateStartGame map model

        OnImportString mapAsJson ->
            case model.maybeMenu of
                Just (MenuImportMap importModel) ->
                    updateOnImportString mapAsJson importModel model |> noCmd

                _ ->
                    noCmd model

        OnMenuButton buttonName ->
            updateOnButton buttonName model

        OnSelectButton name ->
            noCmd (selectButtonByName name model)

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
                    Gamepad.remapUpdate gamepadButtonMap remapMsg remap |> updateOnRemap model

                _ ->
                    noCmd model


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


updateMainScene : Gamepad.Blob -> Model -> ( Model, Cmd a )
updateMainScene blob model =
    case model.scene of
        SceneMain subScene scene ->
            if model.maybeMenu == Nothing || subScene == SubSceneDemo then
                MainScene.updateOnGamepad blob (shell model) scene
                    |> Tuple.mapFirst (\newScene -> { model | scene = SceneMain subScene newScene })
            else
                noCmd model

        _ ->
            noCmd model


updateMenuOnGamepad : Gamepad.Blob -> Model -> ( Model, Cmd Msg )
updateMenuOnGamepad blob model =
    let
        pads =
            Gamepad.getGamepads model.config.gamepadDatabase blob

        buttonClick button =
            List.any (\pad -> Gamepad.wasClicked pad button) pads

        buttonToKey =
            [ ( Gamepad.LeftStickUp, "ArrowUp" )
            , ( Gamepad.LeftStickDown, "ArrowDown" )
            , ( Gamepad.LeftStickLeft, "ArrowLeft" )
            , ( Gamepad.LeftStickRight, "ArrowRight" )
            , ( Gamepad.RightBumper, "Enter" )
            , ( Gamepad.RightTrigger, "Enter" )
            , ( Gamepad.A, "Enter" )
            , ( Gamepad.B, "Escape" )
            ]

        isRemapping =
            case model.maybeMenu of
                Just (MenuGamepads remapModel) ->
                    Gamepad.isRemapping remapModel

                _ ->
                    False
    in
    if isRemapping then
        noCmd model
    else if buttonClick Gamepad.Start then
        updateOnKeyUp "Escape" model
    else if model.maybeMenu == Nothing then
        noCmd model
    else
        case List.Extra.find (\( b, k ) -> buttonClick b) buttonToKey of
            Nothing ->
                noCmd model

            Just ( button, key ) ->
                updateOnKeyUp key model


updateOnGamepad : Gamepad.Blob -> Model -> ( Model, Cmd Msg )
updateOnGamepad blob model =
    model
        |> updateMainScene blob
        |> Tuple.mapFirst (updateMenuOnGamepad blob)
        |> (\( ( m, c1 ), c2 ) -> ( m, Cmd.batch [ c1, c2 ] ))


updateOnKeyUp : String -> Model -> ( Model, Cmd Msg )
updateOnKeyUp keyName model =
    case keyName of
        -- previous
        "ArrowUp" ->
            menuSelectPrevButton model |> noCmd

        "ArrowLeft" ->
            menuSelectPrevButton model |> noCmd

        -- next
        "ArrowDown" ->
            menuSelectNextButton model |> noCmd

        "ArrowRight" ->
            menuSelectNextButton model |> noCmd

        -- back
        "Escape" ->
            menuBack model

        -- "updateOnButton"
        "Enter" ->
            updateOnButton (selectedButtonName model) model

        " " ->
            updateOnButton (selectedButtonName model) model

        -- ignore
        _ ->
            {-
               let
                   _ =
                       Debug.log "key" keyName
               in
            -}
            noCmd model



-- Menu


type alias MenuButton =
    { name : String
    , view : MenuButtonView
    , isVisible : Bool
    , update : Model -> ( Model, Cmd Msg )
    }


type MenuButtonView
    = MenuButtonLabel
    | MenuButtonMap ValidatedMap
    | MenuButtonToggle (Model -> Bool)


menuButtons : Model -> List MenuButton
menuButtons model =
    List.filter .isVisible <|
        case model.maybeMenu of
            Just MenuMain ->
                mainMenuButtons model

            Just MenuMapSelection ->
                mapSelectionMenuButtons model

            Just MenuHowToPlay ->
                [ { name = "Ok"
                  , view = MenuButtonLabel
                  , isVisible = True
                  , update = menuBack
                  }
                ]

            Just MenuSettings ->
                menuSettingsButtons model

            _ ->
                []


menuSettingsButtons : Model -> List MenuButton
menuSettingsButtons model =
    [ -- TODO: move this in the "gamepads" menu? Or disable it?
      { name = "Use Keyboard & Mouse"
      , view = MenuButtonToggle (.config >> .useKeyboardAndMouse)
      , isVisible = True
      , update = updateConfigFlag .useKeyboardAndMouse (\v c -> { c | useKeyboardAndMouse = v })
      }
    , { name = "Show Frames per Second"
      , view = MenuButtonToggle (.config >> .showFps)
      , isVisible = True
      , update = updateConfigFlag .showFps (\v c -> { c | showFps = v })
      }
    ]


updateConfigFlag : (Config -> Bool) -> (Bool -> Config -> Config) -> Model -> ( Model, Cmd Msg )
updateConfigFlag getter setter model =
    updateConfig (\config -> setter (getter config |> not) config) model


mapSelectionMenuButtons : Model -> List MenuButton
mapSelectionMenuButtons model =
    let
        mapToButton index map =
            { name = "map " ++ String.fromInt index
            , view = MenuButtonMap map
            , isVisible = True
            , update = updateStartGame map
            }

        maps =
            OfficialMaps.maps |> List.indexedMap mapToButton

        importButton =
            { name = "Import..."
            , view = MenuButtonLabel
            , isVisible = True
            , update = menuNav (MenuImportMap { importString = "", mapResult = Err "" })
            }
    in
    maps ++ [ importButton ]


updateStartGame : ValidatedMap -> Model -> ( Model, Cmd Msg )
updateStartGame map model =
    noCmd
        { model
            | scene = SceneMain SubSceneGameplay <| MainScene.initTeamSelection model.seed map
            , maybeMenu = Nothing
        }


mainMenuButtons : Model -> List MenuButton
mainMenuButtons model =
    let
        isDemo =
            case model.scene of
                SceneMain SubSceneDemo _ ->
                    True

                _ ->
                    False

        ( isPlaying, isFinished ) =
            case model.scene of
                SceneMain subScene scene ->
                    ( subScene == SubSceneGameplay, scene.game.maybeWinnerTeamId /= Nothing )

                _ ->
                    ( False, False )

        isMapEditor =
            case model.scene of
                SceneMapEditor _ ->
                    True

                _ ->
                    False
    in
    -- Game
    [ { name = "Play"
      , view = MenuButtonLabel
      , isVisible = isDemo
      , update = menuNav MenuMapSelection
      }
    , { name = "Play again"
      , view = MenuButtonLabel
      , isVisible = isPlaying && isFinished
      , update = menuNav MenuMapSelection
      }
    , { name = "Resume"
      , view = MenuButtonLabel
      , isVisible = isPlaying && not isFinished
      , update = menuBack
      }

    --
    , { name = "How to play"
      , view = MenuButtonLabel
      , isVisible = True
      , update = menuNav MenuHowToPlay
      }

    -- Map editor
    , { name = "Map Editor"
      , view = MenuButtonLabel
      , isVisible = isDemo
      , update = menuOpenMapEditor
      }

    -- Config
    , { name = "Settings"
      , view = MenuButtonLabel
      , isVisible = True
      , update = menuNav MenuSettings
      }
    , { name = "Gamepads"
      , view = MenuButtonLabel
      , isVisible = True
      , update = menuNav <| MenuGamepads <| Gamepad.remapInit
      }
    , { name = "Quit"
      , view = MenuButtonLabel
      , isVisible = isPlaying || isMapEditor
      , update = menuDemo
      }
    ]



-- Prevent other functions from accessing the selection directly


type SelectedButton
    = SelectedButton String


selectedButton : Model -> MenuButton
selectedButton model =
    let
        buttons =
            menuButtons model |> List.filter .isVisible
    in
    case List.Extra.find (\b -> SelectedButton b.name == model.selectedButton) buttons of
        Just button ->
            button

        Nothing ->
            case List.head buttons of
                Just button ->
                    button

                Nothing ->
                    { name = "this shouldn't happen", view = MenuButtonLabel, isVisible = False, update = menuDemo }


selectButtonByName : String -> Model -> Model
selectButtonByName name model =
    { model | selectedButton = SelectedButton name }



-- Menu helpers


selectButton : MenuButton -> Model -> Model
selectButton button =
    selectButtonByName button.name


selectedButtonName : Model -> String
selectedButtonName =
    selectedButton >> .name


menuNav : Menu -> Model -> ( Model, Cmd Msg )
menuNav menu oldModel =
    noCmd { oldModel | maybeMenu = Just menu }


menuOpenMapEditor : Model -> ( Model, Cmd Msg )
menuOpenMapEditor model =
    noCmd { model | maybeMenu = Nothing, scene = SceneMapEditor MapEditor.init }


menuDemo : Model -> ( Model, Cmd Msg )
menuDemo model =
    let
        ( scene, seed ) =
            demoScene model.seed
    in
    noCmd { model | scene = scene, seed = seed }


menuBack : Model -> ( Model, Cmd Msg )
menuBack model =
    case model.maybeMenu of
        Just MenuMain ->
            noCmd { model | maybeMenu = Nothing }

        Just (MenuImportMap _) ->
            menuNav MenuMapSelection model

        _ ->
            menuNav MenuMain model


findButton : String -> Model -> Maybe MenuButton
findButton buttonName model =
    List.Extra.find (\button -> button.name == buttonName) (menuButtons model)


updateOnButton : String -> Model -> ( Model, Cmd Msg )
updateOnButton buttonName model =
    case findButton buttonName model of
        Nothing ->
            noCmd model

        Just button ->
            button.update model


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
                |> List.Extra.dropWhile (\b -> b.name /= selectedButtonName model)
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
                |> List.Extra.dropWhile (\b -> b.name /= selectedButtonName model)
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
    [ ( Gamepad.LeftStickLeft, "Move LEFT" )
    , ( Gamepad.LeftStickRight, "Move RIGHT" )
    , ( Gamepad.LeftStickUp, "Move UP" )
    , ( Gamepad.LeftStickDown, "Move DOWN" )

    --
    , ( Gamepad.RightStickLeft, "Aim LEFT" )
    , ( Gamepad.RightStickRight, "Aim RIGHT" )
    , ( Gamepad.RightStickUp, "Aim UP" )
    , ( Gamepad.RightStickDown, "Aim DOWN" )

    --
    , ( Gamepad.RightTrigger, "FIRE" )
    , ( Gamepad.RightBumper, "Alt FIRE" )
    , ( Gamepad.A, "Transform" )
    , ( Gamepad.B, "Rally" )
    , ( Gamepad.Start, "Menu" )
    ]
        |> List.map (\( a, b ) -> ( b, a ))


updateOnRemap : Model -> ( Gamepad.RemapModel, Maybe (UserMappings -> UserMappings) ) -> ( Model, Cmd Msg )
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
                div
                    [ class "fullWindow bgOpaque flex alignCenter justifyCenter"
                    ]
                    [ div
                        [ class "menu p2" ]
                        [ viewMenu menu model ]
                    ]
        ]


viewMenu : Menu -> Model -> Html Msg
viewMenu menu model =
    case menu of
        MenuMain ->
            div
                [ class "flex flexColumn alignCenter" ]
                [ div [ class "mb2" ] [ text "Press Esc or ▶ (Start) to toggle Menu" ]
                , menuButtons model
                    |> List.map (viewMenuButton model)
                    |> div [ class "flex flexColumn" ]
                ]

        MenuMapSelection ->
            div
                []
                [ section
                    [ class "flex flexColumn alignCenter" ]
                    [ div [] [ text "Select map" ]
                    , menuButtons model
                        |> List.filter (\b -> b.view /= MenuButtonLabel)
                        |> List.map (viewMenuButton model)
                        |> div [ class "map-selection" ]
                    ]
                , section
                    [ class "flex justifyCenter" ]
                    [ menuButtons model
                        |> List.filter (\b -> b.view == MenuButtonLabel)
                        |> List.map (viewMenuButton model)
                        |> div []
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

        MenuHowToPlay ->
            div
                [ class "flex flexColumn alignCenter" ]
                [ div [] [ text "> How to Play <" ]
                , section
                    []
                    [ [ "Arrow keys or ASDW to move"
                      , "Q to move the Rally point"
                      , "E to transform"
                      , "Click to fire"
                      , "ESC to toggle the Menu"
                      , "Your goal is to destroy all four drones guarding the main enemy base"
                      , "Rally your drones close to an unoccupied base to conquer it"
                      , "Conquered bases produce more drones and repair your mech"
                      , "Drones inside bases are a lot hardier than free romaing ones"
                      , "When a mech is destroyed, the enemy will produce three special drones"
                      , "Special drones are very strong against other drones, but can't enter bases"
                      ]
                        |> List.map (\t -> li [] [ text t ])
                        |> ul []
                    ]
                , section
                    [ class "flex justifyCenter" ]
                    [ menuButtons model
                        |> List.map (viewMenuButton model)
                        |> div []
                    ]
                ]

        MenuGamepads remap ->
            div
                [ class "flex flexColumn alignCenter" ]
                [ div [ class "mb2" ] [ text "> Gamepads <" ]
                , section
                    []
                    [ Gamepad.remapView
                        gamepadButtonMap
                        model.config.gamepadDatabase
                        remap
                        |> Html.map OnRemapMsg
                    ]
                ]

        MenuSettings ->
            div
                [ class "flex flexColumn alignCenter" ]
                [ div [ class "mb2" ] [ text "> Gamepads <" ]
                , menuButtons model
                    |> List.map (viewMenuButton model)
                    |> div [ class "flex flexColumn" ]
                ]


viewMenuButton : Model -> MenuButton -> Html Msg
viewMenuButton model b =
    let
        isSelected =
            b.name == selectedButtonName model

        borderColor =
            if isSelected then
                "black"
            else
                "transparent"

        ( className, content ) =
            case b.view of
                MenuButtonLabel ->
                    ( "label", [ text b.name ] )

                MenuButtonMap map ->
                    ( "map-preview", [ viewMapPreview model map ] )

                MenuButtonToggle getter ->
                    ( "label flex justifyBetween", viewToggle b.name (getter model) )
    in
    div
        [ class "menu-button"
        , style "border" ("3px solid " ++ borderColor)
        ]
        [ button
            [ onClick (OnMenuButton b.name)
            , onFocus (OnSelectButton b.name)
            , class className
            ]
            content
        ]


viewToggle : String -> Bool -> List (Html a)
viewToggle label state =
    [ span
        []
        [ text label ]
    , span
        []
        [ text <|
            if state then
                "Yes"
            else
                "No"
        ]
    ]


viewMapPreview : Model -> ValidatedMap -> Html Msg
viewMapPreview model map =
    let
        width =
            model.windowSize.width // 6

        size =
            { width = width
            , height = 2 * width // 3
            }

        viewport =
            SplitScreen.makeViewports size 1
                |> List.head
                |> Maybe.withDefault SplitScreen.defaultViewport

        mmmap =
            { name = map.name
            , author = map.author
            , halfWidth = map.halfWidth
            , halfHeight = map.halfHeight
            , bases = map.smallBases |> Set.toList |> List.map (\tile -> ( tile, Game.BaseSmall )) |> Dict.fromList
            , wallTiles = map.wallTiles
            }
    in
    div
        []
        [ View.Game.viewMap [] viewport mmmap ]



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        remapGamepadSub =
            Gamepad.remapSubscriptions GamepadPort.gamepad |> Sub.map OnRemapMsg

        appGamepadSub =
            GamepadPort.gamepad OnGamepad

        gamepad =
            case model.maybeMenu of
                Just (MenuGamepads remap) ->
                    if Gamepad.isRemapping remap then
                        remapGamepadSub
                    else
                        Sub.batch
                            [ appGamepadSub
                            , remapGamepadSub
                            ]

                _ ->
                    appGamepadSub
    in
    Sub.batch
        [ Browser.Events.onKeyDown (Input.keyboardDecoder OnKeyDown)
        , Browser.Events.onKeyUp (Input.keyboardDecoder OnKeyUp)
        , Browser.Events.onVisibilityChange OnVisibilityChange
        , Browser.Events.onMouseDown (OnMouseButton True |> Input.always)
        , Browser.Events.onMouseUp (OnMouseButton False |> Input.always)
        , Browser.Events.onMouseMove (Input.mouseMoveDecoder OnMouseMoves)
        , Browser.Events.onResize OnWindowResizes
        , gamepad
        , case model.scene of
            SceneMapEditor mapEditor ->
                MapEditor.subscriptions mapEditor |> Sub.map OnMapEditorMsg

            _ ->
                Sub.none
        ]
