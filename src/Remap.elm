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


type alias Action =
    ( String, Destination )


type WaitingFor
    = AllButtonsUp
    | SomeButtonDown


type alias Remapping =
    { index : Int
    , map : List ( Origin, Destination )
    , waitingFor : WaitingFor
    }


type alias Model =
    { blob : Blob
    , maybeRemapping : Maybe Remapping
    }


init : Model
init =
    { blob = []
    , maybeRemapping = Nothing
    }


isRemapping : Model -> Bool
isRemapping model =
    model.maybeRemapping /= Nothing



-- Stuff


nextUnmappedAction : List Action -> List ( Origin, Destination ) -> Maybe Action
nextUnmappedAction actions map =
    let
        isNotMapped ( name, destination ) =
            List.all (\( origin, d ) -> d /= destination) map
    in
    List.Extra.find isNotMapped actions



-- Update


noCmd : Model -> ( Model, Maybe (Database -> Database) )
noCmd model =
    ( model, Nothing )


update : List Action -> Msg -> Model -> ( Model, Maybe (Database -> Database) )
update actions msg model =
    case msg of
        Noop ->
            noCmd model

        OnGamepad blob ->
            updateOnGamepad actions { model | blob = blob }

        OnStartRemapping index ->
            noCmd
                { model
                    | maybeRemapping =
                        Just
                            { index = index
                            , map = []
                            , waitingFor = AllButtonsUp
                            }
                }


updateOnGamepad : List Action -> Model -> ( Model, Maybe (Database -> Database) )
updateOnGamepad actions model =
    case model.maybeRemapping of
        Nothing ->
            noCmd model

        Just remapping ->
            case ( remapping.waitingFor, estimateOrigin model.blob remapping.index ) of
                ( AllButtonsUp, Nothing ) ->
                    noCmd { model | maybeRemapping = Just { remapping | waitingFor = SomeButtonDown } }

                ( SomeButtonDown, Just origin ) ->
                    case nextUnmappedAction actions remapping.map of
                        Nothing ->
                            ( { model | maybeRemapping = Nothing }
                            , Just (buttonMapToUpdateDatabase model.blob remapping.index remapping.map)
                            )

                        Just ( name, destination ) ->
                            noCmd
                                { model
                                    | maybeRemapping =
                                        Just
                                            { remapping
                                                | map = ( origin, destination ) :: remapping.map
                                                , waitingFor = AllButtonsUp
                                            }
                                }

                _ ->
                    noCmd model



-- View


view : List Action -> Database -> Model -> Html Msg
view actionNames db model =
    div
        [ class "elm-gamepad" ]
        [ case model.maybeRemapping of
            Just remapping ->
                viewRemapping actionNames remapping

            Nothing ->
                if getIndices model.blob == [] then
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


viewRemapping : List Action -> Remapping -> Html Msg
viewRemapping actions remapping =
    case nextUnmappedAction actions remapping.map of
        Nothing ->
            div
                []
                [ div [] [ text <| "Remapping Gamepad " ++ String.fromInt remapping.index ++ " complete." ]
                , div [] [ text "Press any button to go back." ]

                -- TODO, button [] [ text "Ok!" ]
                ]

        Just ( actionName, destination ) ->
            div
                []
                [ div [] [ text <| "Remapping Gamepad " ++ String.fromInt remapping.index ]
                , div [] [ text "press:" ]
                , div [] [ text actionName ]

                -- TODO, button [] [ text "skip" ]
                -- TODO, button [] [ text "cancel" ]
                ]


findIndex : Int -> List Gamepad -> Maybe Gamepad
findIndex index pads =
    List.Extra.find (\pad -> getIndex pad == index) pads


viewGamepad : List Action -> Database -> Blob -> Int -> Html Msg
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
            [ class "elm-gamepad-remap-button"
            , onClick (OnStartRemapping index)
            ]
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
