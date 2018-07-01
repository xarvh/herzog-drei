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
        [ if getMappedAndUnmappedGamepads db model.blob == [] then
            div
                [ class "elm-gamepad-no-gamepads" ]
                [ text "No gamepads detected" ]
          else
            List.map2 (viewGamepad actionNames)
                -- first time with db
                (getMappedAndUnmappedGamepads db model.blob)
                -- second time without, so we can see which ones are auto configured
                (getMappedAndUnmappedGamepads emptyDatabase model.blob)
                |> ul [ class "elm-gamepad-gamepad-list" ]
        , node "style"
            []
            [ text cssStyle ]
        ]


viewGamepad : List ( String, Destination ) -> MappedOrUnmapped -> MappedOrUnmapped -> Html Msg
viewGamepad actions mappedOrUnmapped mappedOrUnmappedWithoutDatabase =
    let
        symbolNope =
            ( "✘", "elm-gamepad-mapping-unavailable" )

        symbolYeah =
            ( "✔", "elm-gamepad-mapping-available" )

        ( ( symbolFace, symbolClass ), mapState ) =
            case mappedOrUnmapped of
                Unmapped unmappedGamepad ->
                    ( symbolNope, "Needs mapping" )

                Mapped gamepad ->
                    if mappedOrUnmapped == mappedOrUnmappedWithoutDatabase then
                        ( symbolYeah, "Standard mapping" )
                    else
                        ( symbolYeah, "Custom mapping" )

        action =
            case mappedOrUnmapped of
                Unmapped unmappedGamepad ->
                    if True then
                        "idle"
                    else
                        "Receiving signal"

                Mapped gamepad ->
                    actions
                        |> List.Extra.find (Tuple.second >> isPressed gamepad)
                        |> Maybe.map Tuple.first
                        |> Maybe.withDefault "idle"

        ( buttonLabel, index ) =
            case mappedOrUnmapped of
                Unmapped unmappedGamepad ->
                    ( "Map", getIndexUnmapped unmappedGamepad )

                Mapped gamepad ->
                    ( "Remap", getIndex gamepad )
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
