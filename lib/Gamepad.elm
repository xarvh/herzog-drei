module Gamepad
    exposing
        ( Analog(..)
        , Blob
        , Digital(..)
        , Gamepad
        , RemapModel
        , RemapMsg
        , UserMappings
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

{-| You need a JavaScript port to get the gamepad information inside Elm.
You can copy the port files from [port/](https://github.com/xarvh/elm-gamepad/tree/master/port).

Within the library, the raw gamepad information produced by the port is called [Blob](#Blob).

You can get a list of all recognised and connected gamepads with [getGamepads](#getGamepads).

The `Digital` and `Analog` types define names for the controls available on gamepads, and
can be used with various getter functions, such as

    Gamepad.value gamepad LeftTriggerAnalog == 0.1

The library also includes a button remapping tool: the tool is very important because
while many gamepads have [a standard mapping](https://www.w3.org/TR/gamepad/#remapping)
and will be configured automatically, many other gamepads won't; some users will also
want to customise the buttons for comfort or accessibility.

All the user-created mappings are collected together in the `UserMappings` object,
and should be persisted within the browser's local storage or IndexedDB, to save
the user from having to remap the gamepad at every page load.


@docs Blob


# Animation Frame

The library reads the state of the gamepads at every new animation frame of the browser, so if you are using
[https://package.elm-lang.org/packages/elm/browser/latest/Browser-Events#onAnimationFrame](Browser.Events.onAnimationFrame)
or
[https://package.elm-lang.org/packages/elm/browser/latest/Browser-Events#onAnimationFrameDelta](Browser.Events.onAnimationFrameDelta)
you should remove them, and instead use `animationFrameTimestamp` or `animationFrameDelta` to get the frame
timing information from the `Blob`.

@docs animationFrameTimestamp, animationFrameDelta


# User Mappings

@docs UserMappings, emptyUserMappings, userMappingsFromString, userMappingsToString, userMappingsDecoder, encodeUserMappings


# Gamepads

@docs Gamepad, Analog, Digital, getGamepads, getIndex , isPressed , wasClicked , wasReleased , value , leftStickPosition , rightStickPosition , dpadPosition


# Remapping

@docs RemapModel, RemapMsg, remapInit, remapSubscriptions, remapUpdate, remapView, isRemapping, haveUnmappedGamepads

-}

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


{-| The Blob contains the raw gamepad data provided by the browser.

The whole point of this library is to transform the Blob into something
that is nice to use with Elm.

-}
type alias Blob =
    Gamepad.Blob.Blob



-- API ------------------------------------------------------------------------


{-| A gamepad with a known mapping.
You can use all control getters to query its state.
-}
type Gamepad
    = Gamepad Mapping GamepadFrame GamepadFrame



--


type alias Mapping =
    Dict String Origin



-- API ------------------------------------------------------------------------


{-| The collection of button maps created by the user when remapping.
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


{-| This type defines names for all available digital controls, whose
state can be either `True` or `False`.

Since the names cover all controls defined the [W3C draft](https://www.w3.org/TR/gamepad/),
they are used also when when remapping the gamepad, to declare which action should be
bound to which control.

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


{-| Some controls can be accessed also as analog and this type defines special
names for them.
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



--


boolToNumber : Bool -> number
boolToNumber bool =
    if bool then
        1
    else
        0



-- API -----------------------------------------------------------------------


{-| This function gives the time passed between the last browser animation
frame and the current one, in milliseconds.

It is the same value you get when using `Browser.Events.onAnimationFrameDelta`.

    update msg model =
      case msg of
        OnGamepad blob ->
          let
              -- Cap the elapsed time, in case the user hides the page and comes back later.
              deltaTimeInMilliseconds = min 200 (Gamepad.animationFrameDelta blob)

        ...

-}
animationFrameDelta : Blob -> Float
animationFrameDelta ( currentFrame, previousFrame ) =
    currentFrame.timestamp - previousFrame.timestamp



-- API -----------------------------------------------------------------------


{-| This function gives the Posix timestamp of the current browser animation
frame.

It is the same value you get when using `Browser.Events.onAnimationFrame`.

    update msg model =
      case msg of
        OnGamepad blob ->
          let
              posixTimestamp = Gamepad.animationFrame blob

        ...

-}
animationFrameTimestamp : Blob -> Time.Posix
animationFrameTimestamp ( currentFrame, previousFrame ) =
    Time.millisToPosix (floor currentFrame.timestamp)



-- API -----------------------------------------------------------------------


{-| UserMappings without any actual user mapping.

Gamepads that the browser recognises as "standard" will still be usable.

-}
emptyUserMappings : UserMappings
emptyUserMappings =
    UserMappings
        { byIndexAndId = Dict.empty
        , byId = Dict.empty
        }



-- API -----------------------------------------------------------------------


{-| Transforms UserMappings into a JSON string.

    saveUserMappingsToLocalStorageCmd =
        userMappings
            |> Gamepad.userMappingsToString
            |> LocalStoragePort.set 'gamepadUserMappings'

-}
userMappingsToString : UserMappings -> String
userMappingsToString userMappings =
    Json.Encode.encode 0 (encodeUserMappings userMappings)



-- API -----------------------------------------------------------------------


{-| Creates UserMappings from a JSON string.

    userMappings =
        flags.gamepadUserMappings
            |> Gamepad.userMappingsFromString
            |> Result.withDefault Gamepad.emptyUserMappings

-}
userMappingsFromString : String -> Result Json.Decode.Error UserMappings
userMappingsFromString asString =
    Json.Decode.decodeString userMappingsDecoder asString



-- API -----------------------------------------------------------------------


{-| Encodes a UserMappings into a JSON `Value`.
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


{-| Decodes a UserMappings from a JSON `Value`.
-}
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


{-| This function takes the user mappings and the latest blob and returns the
current states of all recognised gamepads.

Only recognised gamepads will be returned; use `haveUnmappedGamepads` to see
if there is any gamepad that can be configured.

    update msg model =
      case OnGamepad blob ->
        let
            isFiring = Gamepad.isPressed Gamepad.A

            playerFiringByIndex =
              blob
                |> Gamepad.getGamepads model.userMappings
                |> List.map (\gamepad -> Gamepad.getIndex isFiring gamepad))
                |> Dict.fromList
        in
            updateState playerFiringByIndex

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


{-| X and Y coordinates (-1 to +1) of the left stick.
-}
leftStickPosition : Gamepad -> { x : Float, y : Float }
leftStickPosition pad =
    { x = value pad LeftX
    , y = value pad LeftY
    }



-- API -----------------------------------------------------------------------


{-| X and Y coordinates (-1 to +1) of the right stick.
-}
rightStickPosition : Gamepad -> { x : Float, y : Float }
rightStickPosition pad =
    { x = value pad RightX
    , y = value pad RightY
    }



-- API -----------------------------------------------------------------------


{-| X and Y coordinates (-1, 0 or +1) of the digital pad.
-}
dpadPosition : Gamepad -> { x : Int, y : Int }
dpadPosition pad =
    let
        toInt d =
            boolToNumber (isPressed pad d)
    in
    { x = toInt DpadRight - toInt DpadLeft
    , y = toInt DpadUp - toInt DpadDown
    }



-- API -----------------------------------------------------------------------


{-| Returns `True` if the button is currently being held down.
-}
isPressed : Gamepad -> Digital -> Bool
isPressed (Gamepad mapping currentFrame previousFrame) digital =
    getAsBool digital mapping currentFrame



-- API -----------------------------------------------------------------------


{-| Returns `True` when a button **changes** from being held down to going back up.
-}
wasReleased : Gamepad -> Digital -> Bool
wasReleased (Gamepad mapping currentFrame previousFrame) digital =
    getAsBool digital mapping previousFrame && not (getAsBool digital mapping currentFrame)



-- API -----------------------------------------------------------------------


{-| Returns `True` when a button **changes** from being up to being pushed down.
-}
wasClicked : Gamepad -> Digital -> Bool
wasClicked (Gamepad mapping currentFrame previousFrame) digital =
    not (getAsBool digital mapping previousFrame) && getAsBool digital mapping currentFrame



-- API -----------------------------------------------------------------------


{-| Returns a single value from an analog control.
-}
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
buttonToAxis =
    boolToNumber



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


{-| [The Elm Architecture](https://guide.elm-lang.org/architecture/) `Msg` type
-}
type RemapMsg
    = Noop
    | OnGamepad Blob
    | OnStartRemapping String Int
    | OnSkip Digital
    | OnCancel



-- API -----------------------------------------------------------------------


{-| The current state of the remap tool
-}
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
    , pairs : List ( Origin, Digital )
    , skipped : List Digital
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
    , pairs = []
    , skipped = []
    , waitingFor = AllButtonsUp
    }



--


nextUnmappedAction : List Action -> Remapping -> Maybe Action
nextUnmappedAction actions remapping =
    let
        mapped =
            List.map Tuple.second remapping.pairs ++ remapping.skipped

        needsMapping ( name, destination ) =
            List.all ((/=) destination) mapped
    in
    List.Extra.find needsMapping actions



-- API -----------------------------------------------------------------------


{-| This function returns `True` if there are connected gamepads that cannot
be autoconfigured and are not in `UserMappings`.
If so, ask the user to remap them!
-}
haveUnmappedGamepads : UserMappings -> Blob -> Bool
haveUnmappedGamepads userMappings blob =
    List.length (getRaw blob) > List.length (getGamepads userMappings blob)



--


getRaw : Blob -> List ( String, Int )
getRaw ( currentBlobFrame, previousBlobFrame ) =
    List.map (\g -> ( g.id, g.index )) currentBlobFrame.gamepads



-- API -----------------------------------------------------------------------


{-| [The Elm Architecture](https://guide.elm-lang.org/architecture/) `init`
-}
remapInit : RemapModel
remapInit =
    RemapModel
        { blob = Gamepad.Blob.emptyBlob
        , maybeRemapping = Nothing
        }



-- API -----------------------------------------------------------------------


{-| Returns `True` if the remap tool is currently guiding the user in
remapping a gamepad.

This is useful because while this happens, you generally want to ignore gamepad
input, as the user is trying to change the _meaning_ of the buttons.

-}
isRemapping : RemapModel -> Bool
isRemapping (RemapModel model) =
    model.maybeRemapping /= Nothing



-- API -----------------------------------------------------------------------


{-| [The Elm Architecture](https://guide.elm-lang.org/architecture/) `update`
function.

When a remapping is finished, it will return a function to update the user
mappings.

You will want to persist the new user mapping, otherwise the user will need
to remap every time tha page reloads.

-}
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

            OnCancel ->
                noCmd { model | maybeRemapping = Nothing }

            OnSkip digital ->
                case model.maybeRemapping of
                    Nothing ->
                        noCmd model

                    Just remapping ->
                        noCmd { model | maybeRemapping = Just { remapping | skipped = digital :: remapping.skipped } }



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


{-| [The Elm Architecture](https://guide.elm-lang.org/architecture/) `view`
function.

You can use it as it is, or customise it with CSS: every element has its
own class name, all names are prefixed with `elm-gamepad`.

-}
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
    String.join "\n"
        [ ".elm-gamepad-mapping-unavailable { color: red; }"
        , ".elm-gamepad-mapping-available { color: green; }"
        , ".elm-gamepad-gamepad-index::before { content: 'Gamepad '; }"
        , ".elm-gamepad-gamepad-index::after { content: ': '; }"
        , ".elm-gamepad-remapping-skip { margin-top: 0.5rem; }"
        , ".elm-gamepad-remapping-cancel { margin-top: 0.5rem; }"
        ]



--


viewRemapping : List Action -> Remapping -> Html RemapMsg
viewRemapping actions remapping =
    let
        statusClass =
            class "elm-gamepad-remapping-tellsUserWhatIsHappening"

        instructionClass =
            class "elm-gamepad-remapping-tellsUserWhatToDo"
    in
    case nextUnmappedAction actions remapping of
        Nothing ->
            div
                [ class "elm-gamepad-remapping-complete" ]
                [ div
                    [ statusClass ]
                    [ text <| "Remapping Gamepad " ++ String.fromInt remapping.index ++ " complete." ]
                , div
                    [ instructionClass ]
                    [ text "Press any button to go back." ]
                ]

        Just ( actionName, destination ) ->
            div
                [ class "elm-gamepad-remapping" ]
                [ div [ statusClass ]
                    [ text <| "Remapping Gamepad " ++ String.fromInt remapping.index ]
                , div [ instructionClass ]
                    [ text "Press:" ]
                , div [ class "elm-gamepad-remapping-action-name" ]
                    [ text actionName ]
                , div [ class "elm-gamepad-remapping-skip" ]
                    [ button
                        [ onClick (OnSkip destination) ]
                        [ text "Skip this action" ]
                    ]
                , div [ class "elm-gamepad-remapping-cancel" ]
                    [ button
                        [ onClick OnCancel ]
                        [ text "Cancel remapping" ]
                    ]
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


{-| This is an alias to make the signature of `remapSubscriptions` a bit more
obvious.
-}
type alias PortSubscription msg =
    (Blob -> msg) -> Sub msg



-- API -----------------------------------------------------------------------


{-| [The Elm Architecture](https://guide.elm-lang.org/architecture/)
`subscriptions` function.

Instead of a model, it takes as an argument the gamepad Port.

    import Gamepad
    import GamepadPort

    ...

    subscriptions : Model -> Sub Msg
    subscriptions model =
      Cmd.batch
        [ Gamepad.remapSubscriptions GamepadPort.gamepad |> Sub.map OnRemapMsg
        , ...
        ]

-}
remapSubscriptions : PortSubscription RemapMsg -> Sub RemapMsg
remapSubscriptions gamepadPort =
    gamepadPort OnGamepad



-- Origin estimation -------------------------------------------------------------


buttonToEstimate : Int -> ( Bool, Float ) -> ( Origin, Float )
buttonToEstimate originIndex ( pressed, v ) =
    ( Origin False Button originIndex, boolToNumber pressed )


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
