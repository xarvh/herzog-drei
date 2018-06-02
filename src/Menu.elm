module Menu exposing (..)

import Dict exposing (Dict)
import Gamepad exposing (Gamepad)
import Gamepad.Remap
import GamepadPort
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Set exposing (Set)


-- Gamepad Button Map


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
    , ( Gamepad.A, "Transform" )
    , ( Gamepad.B, "Rally" )
    ]



-- Msg


type Msg
    = Noop
    | OnGamepad ( Float, Gamepad.Blob )
    | OnToggleKeyboardAndMouse
    | OnStartRemapping Int
    | OnRemapMsg Gamepad.Remap.Msg



-- Model


type alias Model =
    { maybeRemapping : Maybe (Gamepad.Remap.Model String)
    , gamepadIdByIndex : Dict Int String

    -- actual config
    , useKeyboardAndMouse : Bool
    }


init : Model
init =
    { maybeRemapping = Nothing
    , gamepadIdByIndex = Dict.empty

    --
    , useKeyboardAndMouse = True
    }



-- Update


type Outcome
    = StillOpen Model (Cmd Msg)
    | Close


noCmd : Model -> Outcome
noCmd model =
    StillOpen model Cmd.none


update : Msg -> Model -> Outcome
update msg model =
    case msg of
        Noop ->
            StillOpen model Cmd.none

        OnGamepad ( time, gamepadBlob ) ->
            let
                addRaw gamepad idByIndex =
                    Dict.insert (Gamepad.unknownGetIndex gamepad) (Gamepad.unknownGetId gamepad) idByIndex

                gamepadIdByIndex =
                    List.foldl addRaw Dict.empty (Gamepad.getAllGamepadsAsUnknown gamepadBlob)
            in
            noCmd
                { model | gamepadIdByIndex = gamepadIdByIndex }

        OnToggleKeyboardAndMouse ->
            noCmd { model | useKeyboardAndMouse = not model.useKeyboardAndMouse }

        OnStartRemapping index ->
            noCmd { model | maybeRemapping = Just (Gamepad.Remap.init index gamepadButtonMap) }

        OnRemapMsg remapMsg ->
            case model.maybeRemapping of
                Nothing ->
                    noCmd model

                Just remap ->
                    case Gamepad.Remap.update remapMsg remap of
                        Gamepad.Remap.StillOpen newRemap ->
                            noCmd { model | maybeRemapping = Just newRemap }

                        Gamepad.Remap.Error message ->
                            Debug.crash message

                        Gamepad.Remap.UpdateDatabase updateDatabase ->
                            -- TODO
                            Close



-- View


view : Model -> Html Msg
view model =
    let
        noGamepads =
            Dict.size model.gamepadIdByIndex == 0

        actuallyUseKeyboardAndMouse =
            noGamepads || model.useKeyboardAndMouse

        gamepadIndexesGroupedById =
            model.gamepadIdByIndex
                |> Dict.values
                |> Set.fromList
                |> Set.toList
                |> List.map (\id -> model.gamepadIdByIndex |> Dict.filter (\index id_ -> id == id_) |> Dict.keys)

        viewRemapIds ids =
            let
                s =
                    if List.length ids == 1 then
                        ""
                    else
                        "s"

                list =
                    ids |> List.map toString |> String.join ", "

                first =
                    List.head ids |> Maybe.withDefault 0
            in
            button
                [ onClick (OnStartRemapping first)
                ]
                [ "Remap gamepad" ++ s ++ " " ++ list |> text
                ]
    in
    div
        [ class "fullWindow flex alignCenter justifyCenter"
        ]
        [ div
            [ class "bgConfig borderConfig p2" ]
            (case model.maybeRemapping of
                Just remap ->
                    [ remap |> Gamepad.Remap.view |> text
                    ]

                Nothing ->
                    [ section
                        []
                        [ div
                            []
                            [ input
                                [ type_ "checkbox"
                                , checked actuallyUseKeyboardAndMouse
                                , onClick OnToggleKeyboardAndMouse
                                , disabled noGamepads
                                ]
                                []
                            , span
                                []
                                [ text "Use Keyboard & Mouse" ]
                            ]
                        , [ "ASDW: Move"
                          , "Q: Move units"
                          , "E: Transform"
                          , "Click: Fire"
                          ]
                            |> List.map (\t -> div [] [ text t ])
                            |> div []
                        ]
                    , section
                        [ class "mt2" ]
                        [ if noGamepads then
                            text "Could not find any gamepad connected =("
                          else
                            gamepadIndexesGroupedById
                                |> List.map viewRemapIds
                                |> div []
                        ]
                    ]
            )
        ]



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ GamepadPort.gamepad OnGamepad
        , case model.maybeRemapping of
            Nothing ->
                Sub.none

            Just remapping ->
                Gamepad.Remap.subscriptions GamepadPort.gamepad |> Sub.map OnRemapMsg
        ]
