module Remap exposing (..)

-- TODO remove GamepadPort once I get rid of Gamepad.Remap

import Dict exposing (Dict)
import Gamepad exposing (..)
import Gamepad.Remap
import GamepadPort
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import List.Extra


type Msg
    = Noop
    | OnGamepad ( Float, Blob )
    | OnRemapMsg Gamepad.Remap.Msg
    | OnStartRemapping Int



-- Model


type alias Model =
    { buttons : List ( Destination, String )
    , maybeBlob : Maybe Blob
    , maybeRemap : Maybe (Gamepad.Remap.Model String)
    }


init : List ( Destination, String ) -> Model
init buttons =
    -- TODO: keep buttons out of the Model?
    { buttons = buttons
    , maybeBlob = Nothing
    , maybeRemap = Nothing
    }


isRemapping : Model -> Bool
isRemapping model =
    model.maybeRemap /= Nothing


gamepadsCount : Model -> Int
gamepadsCount model =
    case model.maybeBlob of
        Nothing ->
            0

        Just blob ->
            Gamepad.getAllGamepadsAsUnknown blob |> List.length



-- Update


noCmd : Model -> ( Model, Maybe (Database -> Database) )
noCmd model =
    ( model, Nothing )


update : Msg -> Model -> ( Model, Maybe (Database -> Database) )
update msg model =
    case msg of
        Noop ->
            noCmd model

        OnGamepad ( time, blob ) ->
            noCmd { model | maybeBlob = Just blob }

        OnStartRemapping index ->
            noCmd { model | maybeRemap = Just (Gamepad.Remap.init index model.buttons) }

        OnRemapMsg remapMsg ->
            case model.maybeRemap of
                Nothing ->
                    noCmd model

                Just remap ->
                    case Gamepad.Remap.update remapMsg remap of
                        Gamepad.Remap.StillOpen newRemap ->
                            noCmd { model | maybeRemap = Just newRemap }

                        Gamepad.Remap.Error message ->
                            Debug.todo message

                        Gamepad.Remap.UpdateDatabase updateDatabase ->
                            ( { model | maybeRemap = Nothing }, Just updateDatabase )



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
destinationState gamepad d =
    case List.Extra.find (\( dest, getter ) -> dest == d) getters of
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


viewGamepadWithIndex : Database -> Model -> Blob -> Int -> Html Msg
viewGamepadWithIndex db model blob index =
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
        [ "Gamepad #" ++ String.fromInt (index + 1) |> text
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


viewAllGamepadsWithId : Database -> Model -> Blob -> ( String, List Int ) -> Html Msg
viewAllGamepadsWithId db model blob ( id, indexes ) =
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
                span [] [ text "Need mapping" ]
            else if isAuto then
                span [] [ text "Auto mapped" ]
            else
                span [] [ text "Custom mapped" ]

        index =
            List.head indexes |> Maybe.withDefault 0
    in
    div
        []
        [ div
            []
            [ mappingStatus
            , span [] [ text ": " ]
            , button [ onClick (OnStartRemapping index) ] [ text "Remap" ]
            ]

        -- TODO also show number of axes/buttons?
        , indexes
            |> List.sort
            |> List.map (viewGamepadWithIndex db model blob)
            |> ul []
        ]


view : Database -> Model -> Html Msg
view db model =
    case ( model.maybeRemap, model.maybeBlob ) of
        ( Just remap, _ ) ->
            div
                []
                [ div [] [ text "Press: " ]
                , div [] [ Gamepad.Remap.view remap |> text ]
                ]

        ( Nothing, Nothing ) ->
            text "Waiting for gamepad blob..."

        ( Nothing, Just blob ) ->
            case Gamepad.getAllGamepadsAsUnknown blob of
                [] ->
                    text "No Gamepads found"

                allPads ->
                    let
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
                        |> List.map (viewAllGamepadsWithId db model blob)
                        |> div [ class "elm-gamepad-remap" ]



-- Subscriptions


type alias PortSubscription msg =
    (( Float, Blob ) -> msg) -> Sub msg


subscriptions : PortSubscription Msg -> Sub Msg
subscriptions gamepadPort =
    Sub.batch
        [ gamepadPort OnGamepad
        , Gamepad.Remap.subscriptions GamepadPort.gamepad |> Sub.map OnRemapMsg
        ]
