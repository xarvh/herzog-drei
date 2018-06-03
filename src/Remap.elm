module Remap exposing (..)

import Dict exposing (Dict)
import Gamepad exposing (Blob, Database, Destination, Gamepad, UnknownGamepad)
import Gamepad.Remap
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import List.Extra


type Msg
    = Noop
    | OnGamepad ( Float, Blob )



-- Model


type alias Model =
    { buttons : List ( Destination, String )
    , gamepadDatabase : Database
    , maybeBlob : Maybe Blob
    }


init : List ( Destination, String ) -> Database -> Model
init buttons db =
    -- TODO: keep buttons + gamepadDatabase out of the Model?
    { buttons = buttons
    , gamepadDatabase = db
    , maybeBlob = Nothing
    }


isRemapping : Model -> Bool
isRemapping model =
    False


gamepadsCount : Model -> Int
gamepadsCount model =
    case model.maybeBlob of
        Nothing ->
            0

        Just blob ->
            Gamepad.getAllGamepadsAsUnknown blob |> List.length



-- Update


noCmd : Model -> ( Model, Maybe Database )
noCmd model =
    ( model, Nothing )


update : Msg -> Model -> ( Model, Maybe Database )
update msg model =
    case msg of
        Noop ->
            noCmd model

        OnGamepad ( time, blob ) ->
            noCmd { model | maybeBlob = Just blob }



-- View


viewGamepadWithIndex : Database -> Blob -> Int -> Html Msg
viewGamepadWithIndex db blob index =
    let
        maybeRecognised =
            Gamepad.getGamepads db blob
                |> List.Extra.find (\pad -> Gamepad.getIndex pad == index)

        hasSignal =
            Gamepad.getAllGamepadsAsUnknown blob
                |> List.Extra.find (\pad -> Gamepad.unknownGetIndex pad == index)
                |> Maybe.map (Gamepad.estimateOrigin >> (/=) Nothing)
                |> Maybe.withDefault False
    in
    li
        []
        [ "Gamepad #" ++ toString (index + 1) |> text
        , if hasSignal then
            text " (receiving signal)"
          else
            text ""
        ]


viewAllGamepadsWithId : Database -> Blob -> ( String, List Int ) -> Html Msg
viewAllGamepadsWithId db blob ( id, indexes ) =
    let
        findFirst : List Gamepad -> Maybe Gamepad
        findFirst =
            List.Extra.find (\pad -> List.member (Gamepad.getIndex pad) indexes)

        maybeStandardGamepad =
            Gamepad.getGamepads Gamepad.emptyDatabase blob |> findFirst

        maybeRecognised =
            Gamepad.getGamepads db blob |> findFirst

        isAuto =
            maybeStandardGamepad == maybeRecognised

        mappingStatus =
            if maybeRecognised == Nothing then
                -- TODO add an "highlight" class?
                span [] [ text "Needs mapping!" ]
            else if isAuto then
                span [] [ text "Auto mapped" ]
            else
                span [] [ text "Custom mapped" ]
    in
    div
        []
        [ div
            []
            [ mappingStatus
            , span [] [ text ": " ]
            , span [] [ text id ]
            ]

        -- TODO also show number of axes/buttons?
        , indexes
            |> List.sort
            |> List.map (viewGamepadWithIndex db blob)
            |> ul []
        ]


view : Model -> Html Msg
view model =
    case model.maybeBlob of
        Nothing ->
            text ""

        Just blob ->
            let
                allPads =
                    Gamepad.getAllGamepadsAsUnknown blob

                allIndexesForId id =
                    allPads
                        |> List.filter (\pad -> Gamepad.unknownGetId pad == id)
                        |> List.map Gamepad.unknownGetIndex

                gamepadIndexesGroupedById =
                    allPads
                        |> List.map Gamepad.unknownGetId
                        |> List.Extra.unique
                        |> List.map (\id -> ( id, allIndexesForId id ))
            in
            gamepadIndexesGroupedById
                |> List.map (viewAllGamepadsWithId model.gamepadDatabase blob)
                |> div []



-- Subscriptions


type alias PortSubscription =
    (( Float, Blob ) -> Msg) -> Sub Msg


subscriptions : PortSubscription -> Sub Msg
subscriptions gamepadPort =
    gamepadPort OnGamepad
