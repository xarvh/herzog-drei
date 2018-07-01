module Gamepad exposing (..)

{-| A library to make sense of
[navigator.getGamepads()](https://developer.mozilla.org/en-US/docs/Web/API/Navigator/getGamepads)

First things first: you need a JavaScript port to get the return value of
`navigator.getGamepads()` inside Elm.
You can copy the port files from [port/](https://github.com/xarvh/elm-gamepad/tree/master/port).

Within the library, the raw gamepad information produced by the port is called [Blob](#Blob).

You can get a list of all recognised and connected gamepads with [getGamepads](#getGamepads).

To access the information of each [Gamepad](#Gamepad), you can use the button
getters: [aIsPressed](#aIsPressed), [leftX](#leftX),
[rightTriggerValue](#rightTriggerValue) and so on...

Many gamepads have [a standard mapping](https://www.w3.org/TR/gamepad/#remapping)
and will be recognised automatically, but for all other gamepads, or for custom
mappings, you will need a button maps [Database](#Database):
you can default to [emptyDatabase](#emptyDatabase), and include a remapping
tool in your app to allow the user to create the mapping.

You can use the bare bones remapping tool provided in
[Gamepad.Remap](#Gamepad-Remap) or [build your own](#mapping);
[getUnknownGamepads](#getUnknownGamepads) will give you a list of connected
gamepads that need to be mapped.


# Blob

@docs Blob


# Database

@docs Database, emptyDatabase, databaseFromString, databaseToString


# Unknown Gamepads

@docs UnknownGamepad, getUnknownGamepads, unknownGetId, unknownGetIndex


# Gamepads

Depending on the hardware, the drivers and the browser, some input values
will be digital (True or False) and some will be analog (0 to 1 or -1 to 1).

The library hides this complexity and converts the values as necessary.

@docs Gamepad, getGamepads, getIndex


### Face buttons

@docs aIsPressed, bIsPressed, xIsPressed, yIsPressed


### Utility buttons

@docs startIsPressed, backIsPressed, homeIsPressed


### Directional pad

@docs dpadUpIsPressed, dpadDownIsPressed, dpadLeftIsPressed, dpadRightIsPressed, dpadX, dpadY


### Left thumbstick

@docs leftX, leftY, leftStickIsPressed, leftBumperIsPressed, leftTriggerIsPressed, leftTriggerValue


### Right thumbstick

@docs rightX, rightY, rightStickIsPressed, rightBumperIsPressed, rightTriggerIsPressed, rightTriggerValue


# Mapping

These are the functions used to write the remapping tool in [Gamepad.Remap](#Gamepad-Remap).
You need them only if instead of [Gamepad.Remap](#Gamepad-Remap) you want to
write your own remapping tool.

A button map associates a raw gamepad input, the [Origin](#Origin), with a
button name, the [RemapDestination](#RemapDestination).

The steps to create a button map are roughly:

1.  For every [RemapDestination](#RemapDestination) your application requires, you should:
      - Ask the user to press/push it.
      - Use [estimateOrigin](#estimateOrigin) to know which [Origin](#Origin) is being activated.
      - Store this [Origin](#Origin) in a tuple together with its [RemapDestination](#RemapDestination).
2.  Pass the list of `(RemapDestination, Origin)` tuples to [buttonMapToUpdateDatabase](#buttonMapToUpdateDatabase)
    to add the new mapping to your [Database](#Database).

@docs getAllGamepadsAsUnknown, Origin, RemapDestination, estimateOrigin, buttonMapToUpdateDatabase

-}

import Array exposing (Array)
import Dict exposing (Dict)
import Gamepad.Private exposing (GamepadFrame)
import List.Extra
import Regex
import Set exposing (Set)
import Time


-- Types ---------------------------------------------------------------------


{-| A recognised gamepad, whose buttons mapping was found in the Database.
You can use all control getters to query its state.
-}
type Gamepad
    = Gamepad Int Mapping (List GamepadFrame)


{-| A collection of button maps, by gamepad Id.

If you change the mapping for one gamepad, the mapping will change for all the
gamepads of that type (ie, all the gamepads that share that Id).

-}
type Database
    = Database (Dict String Mapping)


{-| An Origin references an input in the javascript [gamepad](https://w3c.github.io/gamepad/)
object.
-}
type Origin
    = Origin Bool OriginType Int


type OriginType
    = Axis
    | Button


type alias Mapping =
    String


{-| A Blob describes the raw return value of `navigator.getGamepads()`.

The whole point of this library is to transform the Blob into something
that is nice to use with Elm.

-}
type alias Blob =
    Gamepad.Private.Blob


type alias Destination =
    Digital


{-| All controls are available in digital

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


{-| Some controls are available in analog

TODO

-}
type Analog
    = LeftX
    | LeftY
    | LeftTriggerAnalog
    | RightX
    | RightY
    | RightTriggerAnalog


type OneOrTwo a
    = One a
    | Two a a



-- Type conversions ----------------------------------------------------------


analogToDestination : Analog -> OneOrTwo Destination
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


destinationToString : Destination -> String
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



-- Blob ----------------------------------------------------------------------


{-| TODO
-}
animationFrameDelta : Blob -> Float
animationFrameDelta blob =
    case blob of
        frameA :: frameB :: fs ->
            frameA.timestamp - frameB.timestamp

        _ ->
            17


{-| TODO
<https://alpha.elm-lang.org/packages/elm/browser/latest/Browser-Events#onAnimationFrame>
-}
animationFrameTimestamp : Blob -> Time.Posix
animationFrameTimestamp blob =
    Time.millisToPosix <|
        case blob of
            [] ->
                0

            frame :: fs ->
                floor frame.timestamp



-- Mapping -------------------------------------------------------------------


listToButtonMap : List ( Origin, Destination ) -> Mapping
listToButtonMap map =
    let
        hasMinus isReverse =
            if isReverse then
                "-"
            else
                ""

        typeToString originType =
            case originType of
                Axis ->
                    "a"

                Button ->
                    "b"

        originToCode (Origin isReverse originType index) =
            hasMinus isReverse ++ typeToString originType ++ String.fromInt index

        tupleDestinationToString ( origin, destination ) =
            ( destinationToString destination, origin )

        tupleToString ( destinationAsString, origin ) =
            destinationAsString ++ ":" ++ originToCode origin
    in
    map
        |> List.map tupleDestinationToString
        |> List.map tupleToString
        |> List.sortBy identity
        |> String.join ","



-- Encoding and decoding Databases


{-| An empty Database.
-}
emptyDatabase : Database
emptyDatabase =
    Database Dict.empty


buttonMapDivider : String
buttonMapDivider =
    ",,,"


{-| Encodes a Database into a String, useful to persist the Database.

    saveDatabaseToLocalStorageCmd =
        gamepadDatabase
            |> databaseToString
            |> LocalStoragePort.set model.gamepadDatabaseKey

-}
databaseToString : Database -> String
databaseToString (Database database) =
    let
        tupleToString ( gamepadId, map ) =
            gamepadId ++ buttonMapDivider ++ map ++ "\n"
    in
    database
        |> Dict.toList
        |> List.map tupleToString
        |> List.sortBy identity
        |> String.join ""


{-| Decodes a Database from a String, useful to load a persisted Database.

    gamepadDatabase =
        flags.gamepadDatabaseAsString
            |> Gamepad.databaseFromString
            |> Result.withDefault Gamepad.emptyDatabase

-}
databaseFromString : String -> Result String Database
databaseFromString databaseAsString =
    let
        stringToTuple dbEntry =
            case String.split buttonMapDivider dbEntry of
                [ id, map ] ->
                    Just ( id, map )

                _ ->
                    Nothing
    in
    databaseAsString
        |> String.split "\n"
        |> List.map stringToTuple
        |> List.filterMap identity
        |> Dict.fromList
        |> Database
        -- TODO: detect and return errors instead of ignoring them silently
        |> Ok



-- Standard button maps


standardButtonMaps : Dict String Mapping
standardButtonMaps =
    Dict.fromList [ ( "standard", listToButtonMap standardGamepadMapping ) ]


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


allDigitals : List Digital
allDigitals =
    List.map Tuple.second standardGamepadMapping



-- Get gamepads


{-| TODO
-}
getGamepads : Database -> Blob -> List Gamepad
getGamepads database blob =
    case blob of
        [] ->
            []

        frame :: fx ->
            List.filterMap (maybeGamepad database blob) frame.gamepads


maybeGamepad : Database -> Blob -> GamepadFrame -> Maybe Gamepad
maybeGamepad database blob frame =
    case getGamepadMapping database frame of
        Nothing ->
            Nothing

        Just mapping ->
            Just <| Gamepad frame.index mapping (List.foldr (addBlobFrame frame.index) [] blob)


addBlobFrame : Int -> Gamepad.Private.BlobFrame -> List GamepadFrame -> List GamepadFrame
addBlobFrame index blobFrame gamepadFrames =
    List.foldl (addGamepadFrame index) gamepadFrames blobFrame.gamepads


addGamepadFrame : Int -> GamepadFrame -> List GamepadFrame -> List GamepadFrame
addGamepadFrame index frame frames =
    if frame.index == index then
        frame :: frames
    else
        frames


getGamepadMapping : Database -> GamepadFrame -> Maybe Mapping
getGamepadMapping (Database database) frame =
    case Dict.get frame.id database of
        Just mapping ->
            Just mapping

        Nothing ->
            Dict.get frame.mapping standardButtonMaps



-- input code helpers


stringToInputType : String -> Maybe OriginType
stringToInputType s =
    case s of
        "a" ->
            Just Axis

        "b" ->
            Just Button

        _ ->
            Nothing


maybeToReverse : Maybe String -> Bool
maybeToReverse maybeReverse =
    case maybeReverse of
        Just "-" ->
            True

        _ ->
            False


regexMatchToInputTuple : Regex.Match -> Maybe ( OriginType, Int, Bool )
regexMatchToInputTuple match =
    case match.submatches of
        _ :: maybeReverse :: (Just inputTypeAsString) :: (Just indexAsString) :: _ ->
            Maybe.map3 (\a b c -> ( a, b, c ))
                (inputTypeAsString |> stringToInputType)
                (indexAsString |> String.toInt)
                (maybeReverse |> maybeToReverse |> Just)

        _ ->
            Nothing


mappingToRawIndex : Destination -> String -> Maybe ( OriginType, Int, Bool )
mappingToRawIndex destination mapping =
    let
        regex =
            "(^|,)" ++ destinationToString destination ++ ":(-)?([a-z]?)([0-9]+)(,|$)"
    in
    mapping
        |> Regex.findAtMost 1 (Regex.fromString regex |> Maybe.withDefault Regex.never)
        |> List.head
        |> Maybe.andThen regexMatchToInputTuple


axisToButton : Float -> Bool
axisToButton n =
    n > 0.1


buttonToAxis : Bool -> Float
buttonToAxis b =
    if b then
        1
    else
        0


reverseAxis : Bool -> Float -> Float
reverseAxis isReverse n =
    if isReverse then
        -n
    else
        n


getAsBool : Destination -> Mapping -> GamepadFrame -> Bool
getAsBool destination mapping frame =
    case mappingToRawIndex destination mapping of
        Nothing ->
            False

        Just ( Axis, index, isReverse ) ->
            Array.get index frame.axes
                |> Maybe.withDefault 0
                |> reverseAxis isReverse
                |> axisToButton

        Just ( Button, index, isReverse ) ->
            Array.get index frame.buttons
                |> Maybe.map Tuple.first
                |> Maybe.withDefault False


getAsFloat : Destination -> Mapping -> GamepadFrame -> Float
getAsFloat destination mapping frame =
    case mappingToRawIndex destination mapping of
        Nothing ->
            0

        Just ( Axis, index, isReverse ) ->
            Array.get index frame.axes
                |> Maybe.withDefault 0
                |> reverseAxis isReverse

        Just ( Button, index, isReverse ) ->
            Array.get index frame.buttons
                |> Maybe.map Tuple.second
                |> Maybe.withDefault 0


getAxis : Destination -> Destination -> Mapping -> GamepadFrame -> Float
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



-- Gamepad getters


{-| Get the index of a known gamepad.
To match the LED indicator on XBOX gamepads, indices start from 1.

    getIndex gamepad == 2

-}
getIndex : Gamepad -> Int
getIndex (Gamepad index mapping frames) =
    index


isPressed : Gamepad -> Digital -> Bool
isPressed (Gamepad index mapping frames) digital =
    case frames of
        [] ->
            False

        frame :: fs ->
            getAsBool digital mapping frame


wasReleased : Gamepad -> Digital -> Bool
wasReleased (Gamepad index mapping frames) digital =
    case frames of
        currentFrame :: previousFrame :: fs ->
            getAsBool digital mapping previousFrame && not (getAsBool digital mapping currentFrame)

        _ ->
            False


wasClicked : Gamepad -> Digital -> Bool
wasClicked (Gamepad index mapping frames) digital =
    case frames of
        currentFrame :: previousFrame :: fs ->
            not (getAsBool digital mapping previousFrame) && getAsBool digital mapping currentFrame

        _ ->
            False


axisValue : Gamepad -> Analog -> Float
axisValue (Gamepad index mapping frames) analog =
    case frames of
        [] ->
            0

        frame :: fs ->
            case analogToDestination analog of
                One positive ->
                    getAsFloat positive mapping frame

                Two negative positive ->
                    getAxis negative positive mapping frame


leftPosition : Gamepad -> { x : Float, y : Float }
leftPosition pad =
    { x = axisValue pad LeftX
    , y = axisValue pad LeftY
    }


rightPosition : Gamepad -> { x : Float, y : Float }
rightPosition pad =
    { x = axisValue pad RightX
    , y = axisValue pad RightY
    }


dpadPosition : Gamepad -> { x : Int, y : Int }
dpadPosition pad =
    -- TODO
    { x = 0
    , y = 0
    }



--
-- Mapping helpers
--
-- This code is used to get an estimate of the buttons/sticks the user is
-- moving given a time series of RawGamepad states
--


{-| TODO
-}
getIndices : Blob -> List Int
getIndices blob =
    case blob of
        [] ->
            []

        frame :: fs ->
            List.map .index frame.gamepads


{-| Buttons are always provided as a (isPressed, value) tuple.
This function ignores one and uses only and always the other.

Is this a good assumption?
Are there cases where both should be considered?

-}
buttonToEstimate : Int -> ( Bool, Float ) -> ( Origin, Float )
buttonToEstimate originIndex ( pressed, value ) =
    ( Origin False Button originIndex, boolToNumber pressed )


boolToNumber : Bool -> number
boolToNumber bool =
    if bool then
        1
    else
        0


axisToEstimate : Int -> Float -> ( Origin, Float )
axisToEstimate originIndex value =
    ( Origin (value < 0) Axis originIndex, abs value )


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
estimateOrigin blob index =
    blob
        |> List.head
        |> Maybe.andThen (.gamepads >> List.Extra.find (\pad -> pad.index == index))
        |> Maybe.andThen estimateOriginInFrame


{-| This function inserts a button map for a given gamepad Id in a [Database](#Database),
replacing any previous mapping for that gamepad Id.

The first argument is the gamepad the map is for.

The second argument is the map itself: a List of [RemapDestination](#RemapDestination)s vs
[Origin](#Origin)s.

The third argument is the [Database](#Database) to update.

-}
buttonMapToUpdateDatabase : Blob -> Int -> List ( Origin, Destination ) -> Database -> Database
buttonMapToUpdateDatabase blob index map (Database database) =
    case blob of
        -- TODO: Error: invalid blob!?
        [] ->
            Database database

        frame :: xs ->
            case List.Extra.find (\pad -> pad.index == index) frame.gamepads of
                -- TODO: error: "invalid index. disconnected?" What if the user has just passed a wrong value?
                -- TODO: need to find a way to wrap blob & index
                Nothing ->
                    Database database

                Just gamepad ->
                    Dict.insert gamepad.id (listToButtonMap map) database |> Database
