module Menu exposing (..)

import Config exposing (Config)
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
    , ( Gamepad.RightBumper, "Alt FIRE" )
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
    }


init : Model
init =
    { remap = Remap.init gamepadButtonMap
    }



-- Update


noCmd : Model -> ( Model, Maybe Config )
noCmd model =
    ( model, Nothing )


update : Msg -> Config -> Model -> ( Model, Maybe Config )
update msg config model =
    case msg of
        Noop ->
            noCmd model

        OnToggleKeyboardAndMouse ->
            ( model, Just { config | useKeyboardAndMouse = not config.useKeyboardAndMouse } )

        OnRemapMsg remapMsg ->
            Remap.update remapMsg model.remap
                |> Tuple.mapFirst (\newRemap -> { model | remap = newRemap })
                |> Tuple.mapSecond (Maybe.map <| \updateDb -> { config | gamepadDatabase = updateDb config.gamepadDatabase })



-- View


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


view : Config -> Model -> Html Msg
view config model =
    div
        [ class "fullWindow flex alignCenter justifyCenter"
        ]
        [ div
            [ class "menu p2" ]
            [ div
                []
                [ section
                    [ class "highlight-animation"]
                    [ text "Press Esc to toggle the Menu" ]
                , if not <| Remap.isRemapping model.remap then
                    viewConfig config model
                  else
                    text ""
                , section
                    []
                    [ Remap.view config.gamepadDatabase model.remap |> Html.map OnRemapMsg
                    ]
                ]
            ]
        ]



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Remap.subscriptions GamepadPort.gamepad |> Sub.map OnRemapMsg
