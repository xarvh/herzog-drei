module Remap exposing (..)

import Dict exposing (Dict)
import Gamepad exposing (..)
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


type Getter
    = Bin (Gamepad -> Bool)
    | Pos (Gamepad -> Float)
    | Neg (Gamepad -> Float)
    | DpadNeg (Gamepad -> Bool) (Gamepad -> Int)
    | DpadPos (Gamepad -> Bool) (Gamepad -> Int)


getters : List ( Destination, Getter )
getters =
    [ ( A, Bin aIsPressed )
    , ( B, Bin bIsPressed )
    , ( X, Bin xIsPressed )
    , ( Y, Bin yIsPressed )
    , ( Start, Bin startIsPressed )
    , ( Back, Bin backIsPressed )
    , ( Home, Bin homeIsPressed )
    , ( LeftLeft, Neg leftX )
    , ( LeftRight, Pos leftX )
    , ( LeftUp, Pos leftY )
    , ( LeftDown, Neg leftY )
    , ( LeftStick, Bin leftStickIsPressed )
    , ( LeftBumper, Bin leftBumperIsPressed )
    , ( LeftTrigger, Pos leftTriggerValue )
    , ( RightLeft, Neg rightX )
    , ( RightRight, Pos rightX )
    , ( RightUp, Pos rightY )
    , ( RightDown, Neg rightY )
    , ( RightStick, Bin rightStickIsPressed )
    , ( RightBumper, Bin rightBumperIsPressed )
    , ( RightTrigger, Pos rightTriggerValue )
    , ( DpadUp, DpadPos dpadUpIsPressed dpadY )
    , ( DpadDown, DpadNeg dpadDownIsPressed dpadY )
    , ( DpadLeft, DpadNeg dpadLeftIsPressed dpadX )
    , ( DpadRight, DpadPos dpadRightIsPressed dpadX )
    ]


getterToState : Gamepad -> Getter -> Bool
getterToState gamepad getter =
    case getter of
        Bin getBinary ->
            getBinary gamepad

        Neg getValue ->
            getValue gamepad < -0.2

        Pos getValue ->
            getValue gamepad > 0.2

        DpadNeg getBinary getValue ->
            getBinary gamepad || getValue gamepad < 0

        DpadPos getBinary getValue ->
            getBinary gamepad || getValue gamepad > 0


destinationState : Gamepad -> Destination -> Bool
destinationState gamepad destination =
    case List.Extra.find (\( dest, getter ) -> dest == destination) getters of
        Nothing ->
            False

        Just ( destination, getter ) ->
            getterToState gamepad getter


firstPadControl : Gamepad -> List ( Destination, String ) -> String
firstPadControl gamepad destinations =
    case List.Extra.find (\( dest, name ) -> destinationState gamepad dest) destinations of
        Just ( destination, name ) ->
            name

        Nothing ->
            if List.any (\( dest, getter ) -> getterToState gamepad getter) getters then
                "(not mapped)"
            else
                ""


viewGamepadWithIndex : Model -> Blob -> Int -> Html Msg
viewGamepadWithIndex model blob index =
    let
        maybeRecognised =
            Gamepad.getGamepads model.gamepadDatabase blob
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
        , text " "
        , text <|
            case maybeRecognised of
                Just pad ->
                    firstPadControl pad model.buttons

                Nothing ->
                    if hasSignal then
                        "(receiving signal)"
                    else
                        ""
        ]


viewAllGamepadsWithId : Model -> Blob -> ( String, List Int ) -> Html Msg
viewAllGamepadsWithId model blob ( id, indexes ) =
    let
        findFirst : List Gamepad -> Maybe Gamepad
        findFirst =
            List.Extra.find (\pad -> List.member (Gamepad.getIndex pad) indexes)

        maybeStandardGamepad =
            Gamepad.getGamepads Gamepad.emptyDatabase blob |> findFirst

        maybeRecognised =
            Gamepad.getGamepads model.gamepadDatabase blob |> findFirst

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
            |> List.map (viewGamepadWithIndex model blob)
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
                        |> List.sortBy Tuple.first
            in
            gamepadIndexesGroupedById
                |> List.map (viewAllGamepadsWithId model blob)
                |> div []



-- Subscriptions


type alias PortSubscription =
    (( Float, Blob ) -> Msg) -> Sub Msg


subscriptions : PortSubscription -> Sub Msg
subscriptions gamepadPort =
    gamepadPort OnGamepad
