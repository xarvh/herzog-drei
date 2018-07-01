module Remap exposing (..)

import Dict exposing (Dict)
import Gamepad exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import List.Extra


cssStyle =
    """
.elm-gamepad-mapping-unavailable { color: red; }
.elm-gamepad-mapping-available { color: green; }
.elm-gamepad-gamepad-index::before { content: "Gamepad "; }
.elm-gamepad-gamepad-index::after { content: ": "; }
    """


type Msg
    = Noop
    | OnGamepad Blob
    | OnStartRemapping Int



-- Model


type alias Model =
    { blob : Blob
    }


init : Model
init =
    { blob = []
    }



-- Update


noCmd : Model -> ( Model, Maybe (Database -> Database) )
noCmd model =
    ( model, Nothing )


update : Msg -> Model -> ( Model, Maybe (Database -> Database) )
update msg model =
    case msg of
        Noop ->
            noCmd model

        OnGamepad blob ->
            noCmd { model | blob = blob }

        OnStartRemapping index ->
            noCmd model



-- View


view : List ( String, Destination ) -> Database -> Model -> Html Msg
view actionNames db model =
    div
        [ class "elm-gamepad" ]
        [ if getIndices model.blob == [] then
            div
                [ class "elm-gamepad-no-gamepads" ]
                [ text "No gamepads detected" ]
          else
            model.blob
                |> getIndices
                |> List.map (viewGamepad actionNames db model.blob)
                |> ul [ class "elm-gamepad-gamepad-list" ]
        , node "style"
            []
            [ text cssStyle ]
        ]


findIndex : Int -> List Gamepad -> Maybe Gamepad
findIndex index pads =
    List.Extra.find (\pad -> getIndex pad == index) pads


viewGamepad : List ( String, Destination ) -> Database -> Blob -> Int -> Html Msg
viewGamepad actions db blob index =
    let
        maybeGamepad =
            findIndex index (getGamepads db blob)

        maybeGamepadWithoutConfig =
            findIndex index (getGamepads emptyDatabase blob)

        symbolNope =
            ( "✘", "elm-gamepad-mapping-unavailable" )

        symbolYeah =
            ( "✔", "elm-gamepad-mapping-available" )

        ( ( symbolFace, symbolClass ), mapState ) =
            case maybeGamepad of
                Nothing ->
                    ( symbolNope, "Needs mapping" )

                Just gamepad ->
                    if maybeGamepad == maybeGamepadWithoutConfig then
                        ( symbolYeah, "Standard mapping" )
                    else
                        ( symbolYeah, "Custom mapping" )

        action =
            case maybeGamepad of
                Nothing ->
                    if estimateOrigin blob index == Nothing then
                        "idle"
                    else
                        "Receiving signal"

                Just gamepad ->
                    actions
                        |> List.Extra.find (Tuple.second >> isPressed gamepad)
                        |> Maybe.map Tuple.first
                        |> Maybe.withDefault "idle"

        buttonLabel =
            case maybeGamepad of
                Nothing ->
                    "Map"

                Just gamepad ->
                    "Remap"
    in
    li
        [ class "elm-gamepad-gamepad-list-item" ]
        [ span
            [ class "elm-gamepad-gamepad-index" ]
            [ text (String.fromInt index) ]
        , span
            [ class symbolClass ]
            [ text symbolFace ]
        , span
            [ class "elm-gamepad-mapping-state-text" ]
            [ text mapState ]
        , div
            [ class "elm-gamepad-current-action-text" ]
            [ text action ]
        , button
            [ class "elm-gamepad-remap-button" ]
            [ text buttonLabel ]
        ]



-- Subscriptions


type alias PortSubscription msg =
    (Blob -> msg) -> Sub msg


subscriptions : PortSubscription Msg -> Sub Msg
subscriptions gamepadPort =
    Sub.batch
        [ gamepadPort OnGamepad
        ]
