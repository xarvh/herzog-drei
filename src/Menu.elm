module Menu exposing (..)

import Dict exposing (Dict)
import Gamepad exposing (Gamepad)
import GamepadPort
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Remap
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
    | OnToggleKeyboardAndMouse
    | OnRemapMsg Remap.Msg



-- Model


type alias Model =
    { remap : Remap.Model

    -- actual config
    , useKeyboardAndMouse : Bool
    }


init : Gamepad.Database -> Model
init db =
    { remap = Remap.init gamepadButtonMap db

    --
    , useKeyboardAndMouse = True
    }



-- Update


noCmd : Model -> ( Model, Maybe Gamepad.Database )
noCmd model =
    ( model, Nothing )


update : Msg -> Model -> ( Model, Maybe Gamepad.Database )
update msg model =
    case msg of
        Noop ->
            noCmd model

        OnToggleKeyboardAndMouse ->
            noCmd { model | useKeyboardAndMouse = not model.useKeyboardAndMouse }

        OnRemapMsg remapMsg ->
            Remap.update remapMsg model.remap
                |> Tuple.mapFirst (\newRemap -> { model | remap = newRemap })



-- View


viewConfig : Model -> Html Msg
viewConfig model =
    let
        noGamepads =
            Remap.gamepadsCount model.remap == 0

        actuallyUseKeyboardAndMouse =
            noGamepads || model.useKeyboardAndMouse

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


view : Model -> Html Msg
view model =
    div
        [ class "fullWindow flex alignCenter justifyCenter"
        ]
        [ div
            [ class "menu p2" ]
            [ div
                []
                [ if not <| Remap.isRemapping model.remap then
                    viewConfig model
                  else
                    text ""
                , section
                    []
                    [ Remap.view model.remap |> Html.map OnRemapMsg
                    ]
                , section
                    [ class "gray" ]
                    [ text "Press Esc to toggle the Menu" ]
                ]
            ]
        ]



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Remap.subscriptions GamepadPort.gamepad |> Sub.map OnRemapMsg
