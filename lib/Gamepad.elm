module Gamepad
    exposing
        ( Analog(..)
        , Blob
        , Digital(..)
        , Gamepad
        , RemapModel
        , RemapMsg
        , UserMappings
        , allDigitalInputs
        , animationFrameDelta
        , animationFrameTimestamp
        , dpadPosition
        , emptyUserMappings
        , encodeUserMappings
        , getGamepads
        , getIndex
        , haveUnmappedGamepads
        , isPressed
        , isRemapping
        , leftStickPosition
        , remapInit
        , remapSubscriptions
        , remapUpdate
        , remapView
        , rightStickPosition
        , userMappingsDecoder
        , userMappingsFromString
        , userMappingsToString
        , value
        , wasClicked
        , wasReleased
        )

import Array exposing (Array)
import Dict exposing (Dict)
import Gamepad.Blob exposing (GamepadFrame)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Json.Decode
import Json.Encode
import List.Extra
import Time


-- API ------------------------------------------------------------------------


{-| A Blob describes the raw return value of `navigator.getGamepads()`.

The whole point of this library is to transform the Blob into something
that is nice to use with Elm.

-}
type alias Blob =
    Gamepad.Blob.Blob



-- API ------------------------------------------------------------------------


{-| A recognised gamepad, whose buttons mapping was found in the Database.
You can use all control getters to query its state.
-}
type Gamepad
    = Gamepad Mapping GamepadFrame GamepadFrame



--


type alias Mapping =
    Dict String Origin



-- API ------------------------------------------------------------------------


{-| A collection of button maps, by gamepad Id.

If you change the mapping for one gamepad, the mapping will change for all the
gamepads of that type (ie, all the gamepads that share that Id).

-}
type UserMappings
    = UserMappings Database



--


type alias Database =
    { byIndexAndId : Dict ( Int, String ) Mapping
    , byId : Dict String Mapping
    }



--


type Origin
    = Origin Bool OriginType Int



--


type OriginType
    = Axis
    | Button



-- API ------------------------------------------------------------------------


{-| All controls are available as digital inputs

TODO

-}
type Digital
    = A
    | B
    | X
    | Y
    | Start
    | Back
    | Home
    | LeftStickPress
    | LeftStickUp
    | LeftStickDown
    | LeftStickLeft
    | LeftStickRight
    | LeftTrigger
    | LeftBumper
    | RightStickPress
    | RightStickUp
    | RightStickDown
    | RightStickLeft
    | RightStickRight
    | RightTrigger
    | RightBumper
    | DpadUp
    | DpadDown
    | DpadLeft
    | DpadRight



--


destinationToString : Digital -> String
destinationToString destination =
    case destination of
        A ->
            "a"

        B ->
            "b"

        X ->
            "x"

        Y ->
            "y"

        Start ->
            "start"

        Back ->
            "back"

        Home ->
            "home"

        LeftStickLeft ->
            "leftleft"

        LeftStickRight ->
            "leftright"

        LeftStickUp ->
            "leftup"

        LeftStickDown ->
            "leftdown"

        LeftStickPress ->
            "leftstick"

        LeftBumper ->
            "leftbumper"

        LeftTrigger ->
            "lefttrigger"

        RightStickLeft ->
            "rightleft"

        RightStickRight ->
            "rightright"

        RightStickUp ->
            "rightup"

        RightStickDown ->
            "rightdown"

        RightStickPress ->
            "rightstick"

        RightBumper ->
            "rightbumper"

        RightTrigger ->
            "righttrigger"

        DpadUp ->
            "dpadup"

        DpadDown ->
            "dpaddown"

        DpadLeft ->
            "dpadleft"

        DpadRight ->
            "dpadright"



-- API ------------------------------------------------------------------------


allDigitalInputs : List Digital
allDigitalInputs =
    [ A
    , B
    , X
    , Y
    , Start
    , Back
    , Home
    , LeftStickPress
    , LeftStickUp
    , LeftStickDown
    , LeftStickLeft
    , LeftStickRight
    , LeftTrigger
    , LeftBumper
    , RightStickPress
    , RightStickUp
    , RightStickDown
    , RightStickLeft
    , RightStickRight
    , RightTrigger
    , RightBumper
    , DpadUp
    , DpadDown
    , DpadLeft
    , DpadRight
    ]



-- API ------------------------------------------------------------------------


{-| Some controls are available as analog

TODO

-}
type Analog
    = LeftX
    | LeftY
    | LeftTriggerAnalog
    | RightX
    | RightY
    | RightTriggerAnalog



--


type OneOrTwo a
    = One a
    | Two a a



--


analogToDestination : Analog -> OneOrTwo Digital
analogToDestination analog =
    case analog of
        LeftX ->
            Two LeftStickLeft LeftStickRight

        LeftY ->
            Two LeftStickDown LeftStickUp

        LeftTriggerAnalog ->
            One LeftTrigger

        RightX ->
            Two RightStickLeft RightStickRight

        RightY ->
            Two RightStickDown RightStickUp

        RightTriggerAnalog ->
            One RightTrigger



-- API -----------------------------------------------------------------------


{-| TODO
-}
animationFrameDelta : Blob -> Float
animationFrameDelta ( currentFrame, previousFrame ) =
    currentFrame.timestamp - previousFrame.timestamp



-- API -----------------------------------------------------------------------


{-| TODO
<https://alpha.elm-lang.org/packages/elm/browser/latest/Browser-Events#onAnimationFrame>
-}
animationFrameTimestamp : Blob -> Time.Posix
animationFrameTimestamp ( currentFrame, previousFrame ) =
    Time.millisToPosix (floor currentFrame.timestamp)



-- API -----------------------------------------------------------------------


{-| An empty UserMappings.
-}
emptyUserMappings : UserMappings
emptyUserMappings =
    UserMappings
        { byIndexAndId = Dict.empty
        , byId = Dict.empty
        }



-- API -----------------------------------------------------------------------


userMappingsToString : UserMappings -> String
userMappingsToString userMappings =
    Json.Encode.encode 0 (encodeUserMappings userMappings)



-- API -----------------------------------------------------------------------


userMappingsFromString : String -> Result Json.Decode.Error UserMappings
userMappingsFromString asString =
    Json.Decode.decodeString userMappingsDecoder asString



-- API -----------------------------------------------------------------------


{-| Encodes a UserMappings into a String, useful to persist the UserMappings.

    saveDatabaseToLocalStorageCmd =
        gamepadDatabase
            |> databaseToString
            |> LocalStoragePort.set model.gamepadDatabaseKey

-}
encodeUserMappings : UserMappings -> Json.Encode.Value
encodeUserMappings (UserMappings database) =
    let
        encodeTuples : ( ( Int, String ), Mapping ) -> Json.Encode.Value
        encodeTuples ( ( index, id ), mapping ) =
            Json.Encode.object
                [ ( "index", Json.Encode.int index )
                , ( "id", Json.Encode.string id )
                , ( "mapping", encodeMapping mapping )
                ]

        encodeMapping : Mapping -> Json.Encode.Value
        encodeMapping mapping =
            Json.Encode.dict identity encodeOrigin mapping

        encodeOrigin : Origin -> Json.Encode.Value
        encodeOrigin (Origin isReverse type_ index) =
            Json.Encode.object
                [ ( "isReverse", Json.Encode.bool isReverse )
                , ( "type", encodeOriginType type_ )
                , ( "index", Json.Encode.int index )
                ]

        encodeOriginType : OriginType -> Json.Encode.Value
        encodeOriginType t =
            Json.Encode.string <|
                case t of
                    Axis ->
                        "axis"

                    Button ->
                        "button"
    in
    database.byIndexAndId
        |> Dict.toList
        |> Json.Encode.list encodeTuples



-- API -----------------------------------------------------------------------


userMappingsDecoder : Json.Decode.Decoder UserMappings
userMappingsDecoder =
    let
        tuplesDecoder : Json.Decode.Decoder ( ( Int, String ), Mapping )
        tuplesDecoder =
            Json.Decode.map2 Tuple.pair
                keyDecoder
                (Json.Decode.field "mapping" (Json.Decode.dict originDecoder))

        keyDecoder : Json.Decode.Decoder ( Int, String )
        keyDecoder =
            Json.Decode.map2 Tuple.pair
                (Json.Decode.field "index" Json.Decode.int)
                (Json.Decode.field "id" Json.Decode.string)

        originDecoder : Json.Decode.Decoder Origin
        originDecoder =
            Json.Decode.map3 Origin
                (Json.Decode.field "isReverse" Json.Decode.bool)
                (Json.Decode.field "type" (Json.Decode.string |> Json.Decode.andThen stringToOriginType))
                (Json.Decode.field "index" Json.Decode.int)

        stringToOriginType : String -> Json.Decode.Decoder OriginType
        stringToOriginType s =
            case s of
                "axis" ->
                    Json.Decode.succeed Axis

                "button" ->
                    Json.Decode.succeed Button

                _ ->
                    Json.Decode.fail "unrecognised Origin Type"

        listToUserMappings : List ( ( Int, String ), Mapping ) -> UserMappings
        listToUserMappings listByIndexAndId =
            UserMappings
                { byIndexAndId = Dict.fromList listByIndexAndId
                , byId =
                    listByIndexAndId
                        |> List.map (Tuple.mapFirst Tuple.second)
                        |> Dict.fromList
                }
    in
    Json.Decode.list tuplesDecoder
        |> Json.Decode.map listToUserMappings



-- API -----------------------------------------------------------------------


{-| TODO
-}
getGamepads : UserMappings -> Blob -> List Gamepad
getGamepads userMappings ( currentBlobFrame, previousBlobFrame ) =
    let
        getGamepad : GamepadFrame -> Maybe Gamepad
        getGamepad currentGamepadFrame =
            Maybe.map2 (\previousGamepadFrame mapping -> Gamepad mapping currentGamepadFrame previousGamepadFrame)
                (List.Extra.find (\prev -> prev.index == currentGamepadFrame.index) previousBlobFrame.gamepads)
                (getGamepadMapping userMappings currentGamepadFrame)
    in
    List.filterMap getGamepad currentBlobFrame.gamepads



--


getGamepadMapping : UserMappings -> GamepadFrame -> Maybe Mapping
getGamepadMapping (UserMappings database) frame =
    case Dict.get ( frame.index, frame.id ) database.byIndexAndId of
        Just mapping ->
            Just mapping

        Nothing ->
            if frame.mapping == "standard" then
                Just standardGamepadMapping
            else
                Dict.get frame.id database.byId



--


standardGamepadMapping : Mapping
standardGamepadMapping =
    -- https://www.w3.org/TR/gamepad/#remapping
    [ ( A, Origin False Button 0 )
    , ( B, Origin False Button 1 )
    , ( X, Origin False Button 2 )
    , ( Y, Origin False Button 3 )

    --
    , ( Start, Origin False Button 9 )
    , ( Back, Origin False Button 8 )
    , ( Home, Origin False Button 16 )

    --
    , ( LeftStickLeft, Origin True Axis 0 )
    , ( LeftStickRight, Origin False Axis 0 )
    , ( LeftStickUp, Origin True Axis 1 )
    , ( LeftStickDown, Origin False Axis 1 )
    , ( LeftStickPress, Origin False Button 10 )
    , ( LeftBumper, Origin False Button 4 )
    , ( LeftTrigger, Origin False Button 6 )

    --
    , ( RightStickLeft, Origin True Axis 2 )
    , ( RightStickRight, Origin False Axis 2 )
    , ( RightStickUp, Origin True Axis 3 )
    , ( RightStickDown, Origin False Axis 3 )
    , ( RightStickPress, Origin False Button 11 )
    , ( RightBumper, Origin False Button 5 )
    , ( RightTrigger, Origin False Button 7 )

    --
    , ( DpadUp, Origin False Button 12 )
    , ( DpadDown, Origin False Button 13 )
    , ( DpadLeft, Origin False Button 14 )
    , ( DpadRight, Origin False Button 15 )
    ]
        |> List.map (\( a, b ) -> ( b, a ))
        |> pairsToMapping



--


pairsToMapping : List ( Origin, Digital ) -> Mapping
pairsToMapping pairs =
    pairs
        |> List.map (\( origin, digital ) -> ( destinationToString digital, origin ))
        |> Dict.fromList



-- API -----------------------------------------------------------------------


{-| Get the index of a known gamepad.
To match the LED indicator on XBOX gamepads, indices start from 1.

    getIndex gamepad == 2

-}
getIndex : Gamepad -> Int
getIndex (Gamepad mapping currentFrame previousFrame) =
    currentFrame.index



-- API -----------------------------------------------------------------------


leftStickPosition : Gamepad -> { x : Float, y : Float }
leftStickPosition pad =
    { x = value pad LeftX
    , y = value pad LeftY
    }



-- API -----------------------------------------------------------------------


rightStickPosition : Gamepad -> { x : Float, y : Float }
rightStickPosition pad =
    { x = value pad RightX
    , y = value pad RightY
    }



-- API -----------------------------------------------------------------------


dpadPosition : Gamepad -> { x : Int, y : Int }
dpadPosition pad =
    -- TODO
    { x = 0
    , y = 0
    }



-- API -----------------------------------------------------------------------


isPressed : Gamepad -> Digital -> Bool
isPressed (Gamepad mapping currentFrame previousFrame) digital =
    getAsBool digital mapping currentFrame



-- API -----------------------------------------------------------------------


wasReleased : Gamepad -> Digital -> Bool
wasReleased (Gamepad mapping currentFrame previousFrame) digital =
    getAsBool digital mapping previousFrame && not (getAsBool digital mapping currentFrame)



-- API -----------------------------------------------------------------------


wasClicked : Gamepad -> Digital -> Bool
wasClicked (Gamepad mapping currentFrame previousFrame) digital =
    not (getAsBool digital mapping previousFrame) && getAsBool digital mapping currentFrame



-- API -----------------------------------------------------------------------


value : Gamepad -> Analog -> Float
value (Gamepad mapping currentFrame previousFrame) analog =
    case analogToDestination analog of
        One positive ->
            getAsFloat positive mapping currentFrame

        Two negative positive ->
            getAxis negative positive mapping currentFrame


mappingToOrigin : Digital -> Mapping -> Maybe Origin
mappingToOrigin destination mapping =
    Dict.get (destinationToString destination) mapping



--


axisToButton : Float -> Bool
axisToButton n =
    n > 0.6



--


buttonToAxis : Bool -> Float
buttonToAxis b =
    if b then
        1
    else
        0



--


reverseAxis : Bool -> Float -> Float
reverseAxis isReverse n =
    if isReverse then
        -n
    else
        n



--


getAsBool : Digital -> Mapping -> GamepadFrame -> Bool
getAsBool destination mapping frame =
    case mappingToOrigin destination mapping of
        Nothing ->
            False

        Just (Origin isReverse Axis index) ->
            Array.get index frame.axes
                |> Maybe.withDefault 0
                |> reverseAxis isReverse
                |> axisToButton

        Just (Origin isReverse Button index) ->
            Array.get index frame.buttons
                |> Maybe.map Tuple.first
                |> Maybe.withDefault False



--


getAsFloat : Digital -> Mapping -> GamepadFrame -> Float
getAsFloat destination mapping frame =
    case mappingToOrigin destination mapping of
        Nothing ->
            0

        Just (Origin isReverse Axis index) ->
            Array.get index frame.axes
                |> Maybe.withDefault 0
                |> reverseAxis isReverse

        Just (Origin isReverse Button index) ->
            Array.get index frame.buttons
                |> Maybe.map Tuple.second
                |> Maybe.withDefault 0



--


getAxis : Digital -> Digital -> Mapping -> GamepadFrame -> Float
getAxis negativeDestination positiveDestination mapping frame =
    let
        negative =
            getAsFloat negativeDestination mapping frame

        positive =
            getAsFloat positiveDestination mapping frame
    in
    -- if both point to the same Origin, we need just one
    if positive == -negative then
        positive
    else
        positive - negative



-- API -----------------------------------------------------------------------


type RemapMsg
    = Noop
    | OnGamepad Blob
    | OnStartRemapping String Int



-- API -----------------------------------------------------------------------


type RemapModel
    = RemapModel Model



--


type alias Model =
    { blob : Blob
    , maybeRemapping : Maybe Remapping
    }



--


type alias Remapping =
    { id : String
    , index : Int
    , maybeError : Maybe String
    , pairs : List ( Origin, Digital )
    , waitingFor : WaitingFor
    }



--


type alias Action =
    ( String, Digital )



--


type WaitingFor
    = AllButtonsUp
    | SomeButtonDown



--


initRemap : String -> Int -> Remapping
initRemap id index =
    { id = id
    , index = index
    , maybeError = Nothing
    , pairs = []
    , waitingFor = AllButtonsUp
    }



--


nextUnmappedAction : List Action -> Remapping -> Maybe Action
nextUnmappedAction actions remapping =
    let
        isNotMapped ( name, destination ) =
            List.all (\( o, d ) -> d /= destination) remapping.pairs
    in
    List.Extra.find isNotMapped actions



-- API -----------------------------------------------------------------------


haveUnmappedGamepads : UserMappings -> Blob -> Bool
haveUnmappedGamepads userMappings blob =
    List.length (getRaw blob) > List.length (getGamepads userMappings blob)



--


getRaw : Blob -> List ( String, Int )
getRaw ( currentBlobFrame, previousBlobFrame ) =
    List.map (\g -> ( g.id, g.index )) currentBlobFrame.gamepads



-- API -----------------------------------------------------------------------


remapInit : RemapModel
remapInit =
    RemapModel
        { blob = Gamepad.Blob.emptyBlob
        , maybeRemapping = Nothing
        }



-- API -----------------------------------------------------------------------


isRemapping : RemapModel -> Bool
isRemapping (RemapModel model) =
    model.maybeRemapping /= Nothing



-- API -----------------------------------------------------------------------


remapUpdate : List ( String, Digital ) -> RemapMsg -> RemapModel -> ( RemapModel, Maybe (UserMappings -> UserMappings) )
remapUpdate actions msg (RemapModel model) =
    Tuple.mapFirst RemapModel <|
        case msg of
            Noop ->
                noCmd model

            OnGamepad blob ->
                updateOnGamepad actions { model | blob = blob }

            OnStartRemapping id index ->
                noCmd { model | maybeRemapping = Just (initRemap id index) }



--


noCmd : a -> ( a, Maybe (UserMappings -> UserMappings) )
noCmd model =
    ( model, Nothing )



--


updateOnGamepad : List Action -> Model -> ( Model, Maybe (UserMappings -> UserMappings) )
updateOnGamepad actions model =
    case model.maybeRemapping of
        Nothing ->
            noCmd model

        Just remapping ->
            updateRemapping actions remapping model
                |> Tuple.mapFirst (\r -> { model | maybeRemapping = r })



--


updateRemapping : List Action -> Remapping -> Model -> ( Maybe Remapping, Maybe (UserMappings -> UserMappings) )
updateRemapping actions remapping model =
    case ( remapping.waitingFor, estimateOrigin model.blob remapping.index ) of
        ( AllButtonsUp, Nothing ) ->
            noCmd <| Just <| { remapping | waitingFor = SomeButtonDown }

        ( SomeButtonDown, Just origin ) ->
            case nextUnmappedAction actions remapping of
                Nothing ->
                    ( Nothing
                    , Just (pairsToUpdateUserMappings remapping.id remapping.index remapping.pairs)
                    )

                Just ( name, destination ) ->
                    noCmd <| Just <| insertPair origin destination { remapping | waitingFor = AllButtonsUp }

        _ ->
            noCmd <| Just <| remapping



--


insertPair : Origin -> Digital -> Remapping -> Remapping
insertPair origin destination remapping =
    { remapping | pairs = ( origin, destination ) :: remapping.pairs }



--


pairsToUpdateUserMappings : String -> Int -> List ( Origin, Digital ) -> UserMappings -> UserMappings
pairsToUpdateUserMappings id index pairs (UserMappings database) =
    let
        mapping =
            pairsToMapping pairs
    in
    UserMappings
        { byIndexAndId = Dict.insert ( index, id ) mapping database.byIndexAndId
        , byId = Dict.insert id mapping database.byId
        }



-- API -----------------------------------------------------------------------


remapView : List Action -> UserMappings -> RemapModel -> Html RemapMsg
remapView actionNames db (RemapModel model) =
    div
        [ class "elm-gamepad" ]
        [ case model.maybeRemapping of
            Just remapping ->
                viewRemapping actionNames remapping

            Nothing ->
                case getRaw model.blob of
                    [] ->
                        div
                            [ class "elm-gamepad-no-gamepads" ]
                            [ text "No gamepads detected" ]

                    idsAndIndices ->
                        idsAndIndices
                            |> List.map (viewGamepad actionNames db model.blob)
                            |> ul [ class "elm-gamepad-gamepad-list" ]
        , node "style"
            []
            [ text cssStyle ]
        ]



--


cssStyle =
    """
.elm-gamepad-mapping-unavailable { color: red; }
.elm-gamepad-mapping-available { color: green; }
.elm-gamepad-gamepad-index::before { content: "Gamepad "; }
.elm-gamepad-gamepad-index::after { content: ": "; }
    """



--


viewRemapping : List Action -> Remapping -> Html RemapMsg
viewRemapping actions remapping =
    case nextUnmappedAction actions remapping of
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



--


findIndex : Int -> List Gamepad -> Maybe Gamepad
findIndex index pads =
    List.Extra.find (\pad -> getIndex pad == index) pads



--


viewGamepad : List Action -> UserMappings -> Blob -> ( String, Int ) -> Html RemapMsg
viewGamepad actions userMappings blob ( id, index ) =
    let
        maybeGamepad =
            findIndex index (getGamepads userMappings blob)

        maybeGamepadWithoutConfig =
            findIndex index (getGamepads emptyUserMappings blob)

        { symbolFace, symbolClass, buttonLabel, status, signal } =
            case maybeGamepad of
                Nothing ->
                    { symbolFace = "✘"
                    , symbolClass = "elm-gamepad-mapping-unavailable"
                    , buttonLabel = "Map"
                    , status = "Needs mapping"
                    , signal =
                        if estimateOrigin blob index == Nothing then
                            "idle"
                        else
                            "Receiving signal"
                    }

                Just gamepad ->
                    { symbolFace = "✔"
                    , symbolClass = "elm-gamepad-mapping-available"
                    , buttonLabel = "Remap"
                    , status =
                        if maybeGamepad == maybeGamepadWithoutConfig then
                            "Standard mapping"
                        else
                            "Custom mapping"
                    , signal =
                        actions
                            |> List.Extra.find (Tuple.second >> isPressed gamepad)
                            |> Maybe.map Tuple.first
                            |> Maybe.withDefault "idle"
                    }
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
            [ text status ]
        , div
            [ class "elm-gamepad-current-action-text" ]
            [ text signal ]
        , button
            [ class "elm-gamepad-remap-button"
            , onClick (OnStartRemapping id index)
            ]
            [ text buttonLabel ]
        ]



-- API -----------------------------------------------------------------------


type alias PortSubscription msg =
    (Blob -> msg) -> Sub msg



-- API -----------------------------------------------------------------------


remapSubscriptions : PortSubscription RemapMsg -> Sub RemapMsg
remapSubscriptions gamepadPort =
    gamepadPort OnGamepad



-- Origin estimation -------------------------------------------------------------


buttonToEstimate : Int -> ( Bool, Float ) -> ( Origin, Float )
buttonToEstimate originIndex ( pressed, v ) =
    ( Origin False Button originIndex, boolToNumber pressed )


boolToNumber : Bool -> number
boolToNumber bool =
    if bool then
        1
    else
        0


axisToEstimate : Int -> Float -> ( Origin, Float )
axisToEstimate originIndex v =
    ( Origin (v < 0) Axis originIndex, abs v )


estimateThreshold : ( Origin, Float ) -> Maybe Origin
estimateThreshold ( origin, confidence ) =
    if confidence < 0.5 then
        Nothing
    else
        Just origin


estimateOriginInFrame : GamepadFrame -> Maybe Origin
estimateOriginInFrame frame =
    let
        axesEstimates =
            Array.indexedMap axisToEstimate frame.axes

        buttonsEstimates =
            Array.indexedMap buttonToEstimate frame.buttons
    in
    Array.append axesEstimates buttonsEstimates
        |> Array.toList
        |> List.sortBy Tuple.second
        |> List.reverse
        |> List.head
        |> Maybe.andThen estimateThreshold


{-| This function guesses the Origin currently activated by the user.
-}
estimateOrigin : Blob -> Int -> Maybe Origin
estimateOrigin ( currentBlobFrame, previousBlobFrame ) index =
    currentBlobFrame.gamepads
        |> List.Extra.find (\pad -> pad.index == index)
        |> Maybe.andThen estimateOriginInFrame
