module Gamepad.Remap
    exposing
        ( Model
        , Msg
        , Outcome(..)
        , PortSubscription
        , getCurrentButton
        , getTargetGamepadIndex
        , init
        , skipCurrentButton
        , subscriptions
          -- utility
        , testMsg
        , update
        , view
        )

{-| This module contains the [Elm Architecture](#https://guide.elm-lang.org/architecture/)
functions and types that you can use to quickly add bare bones gamepad
remapping capabilities to your app.

If you prefer to write your own remapping tool, you can use this as a guide.

You give the tool the list of `Gamepad.Destination`s your application needs
and the index of the gamepad to remap: the tool will then show the destinations
one by one, and associate each with whatever button/stick the user moves.

You can abort the remapping simply by stopping to show it and ignoring its `Msg`s.

Remember that, once added to a Database, the remap will affect all gamepads of the same
type (ie, with the same id).


# Elm Architecture

@docs Model, Msg, init, update, Outcome, view, subscriptions, PortSubscription


# Utility

@docs getCurrentButton, getTargetGamepadIndex, skipCurrentButton, testMsg

-}

import Dict exposing (Dict)
import Gamepad exposing (Destination, UnknownGamepad)


{-| This describes the outcome of a change in the Model.

`StillOpen` means that the user is still remapping.

`Error` means that something went wrong.

`UpdateDatabase` means that the user is done; we can use the provided
function `Database -> Database` to insert the new map in our database.

    updatedModel =
        case Gamepad.Remap.update remapMsg remapModel of
            StillOpen updatedRemapModel ->
                { model | maybeRemapModel = Just updatedRemapModel }

            Error message ->
                { model
                    | maybeRemapModel = Nothing
                    , maybeErrorMessage = Just message
                }

            UpdateDatabase updateDatabase ->
                { model
                    | maybeRemapModel = Nothing
                    , gamepadDatabase = updateDatabase model.gamepadDatabase
                }

-}
type Outcome presentation
    = StillOpen (Model presentation)
    | Error String
    | UpdateDatabase (Gamepad.Database -> Gamepad.Database)


type alias ConfiguredEntry =
    { destination : Destination
    , origin : Gamepad.Origin
    }


type InputState
    = WaitingForAllButtonsUp
    | WaitingForAnyButtonDown


type alias UnconfiguredButtons presentation =
    List ( Destination, presentation )


type alias ModelRecord presentation =
    { configuredButtons : List ConfiguredEntry
    , inputState : InputState
    , targetUnknownGamepad : UnknownGamepad
    , unconfiguredButtons : UnconfiguredButtons presentation
    }


{-| This describes the state of the tool.
`presentation` is whatever type you want to use to present a
`Gamepad.Destination` to the user.
-}
type Model presentation
    = Ready (ModelRecord presentation)
    | WaitingForGamepad Int (UnconfiguredButtons presentation)


{-| -}
type Msg
    = OnGamepad ( Float, Gamepad.Blob )


{-| This is for testing only. Don't use it.
-}
testMsg : Gamepad.Blob -> Msg
testMsg blob =
    OnGamepad ( 16.6, blob )



-- helpers


indexToUnknownGamepad : Gamepad.Blob -> Int -> Maybe UnknownGamepad
indexToUnknownGamepad blob index =
    let
        isTargetGamepad unknownGamepad =
            Gamepad.unknownGetIndex unknownGamepad == index
    in
    blob
        |> Gamepad.getAllGamepadsAsUnknown
        |> List.filter isTargetGamepad
        |> List.head


notConnectedError : Int -> Outcome presentation
notConnectedError gamepadIndex =
    Error <| "Gamepad " ++ String.fromInt gamepadIndex ++ " is not connected"


{-| The first argument is the index of the gamepad you want to remap.

The second is a list of the inputs you app needs: each is a tuple with
a `Gamepad.Destination` and any object you want to use to present
that destination to the user, such as a String or Svg or an animation
that explains to the user what that button is used for in your app.

-}
init : Int -> List ( Destination, presentation ) -> Model presentation
init gamepadIndex buttonsToConfigure =
    WaitingForGamepad gamepadIndex buttonsToConfigure


actuallyInit : Gamepad.Blob -> Int -> UnconfiguredButtons presentation -> Outcome presentation
actuallyInit blob gamepadIndex buttonsToConfigure =
    case indexToUnknownGamepad blob gamepadIndex of
        Nothing ->
            notConnectedError gamepadIndex

        Just targetUnknownGamepad ->
            { configuredButtons = []
            , unconfiguredButtons = buttonsToConfigure
            , inputState = WaitingForAllButtonsUp
            , targetUnknownGamepad = targetUnknownGamepad
            }
                |> Ready
                |> StillOpen



-- update


configuredButtonsToOutcome : UnknownGamepad -> List ConfiguredEntry -> Outcome a
configuredButtonsToOutcome targetUnknownGamepad configuredButtons =
    let
        configuredButtonToTuple button =
            ( button.destination, button.origin )

        map =
            configuredButtons
                |> List.map configuredButtonToTuple
    in
    Gamepad.buttonMapToUpdateDatabase targetUnknownGamepad map |> UpdateDatabase


{-| You can use this function to allow the user to skip mapping the current
destination.

For example, you can trigger it when the user presses the Space key, or create a
"Skip" `<button>` and trigger it `onClick`.

-}
skipCurrentButton : Model presentation -> Outcome presentation
skipCurrentButton unionModel =
    case unionModel of
        WaitingForGamepad gamepadIndex buttonsToConfigure ->
            StillOpen unionModel

        Ready recordModel ->
            case recordModel.unconfiguredButtons of
                -- This should not happen, but we can recover without loss of consistency
                [] ->
                    configuredButtonsToOutcome recordModel.targetUnknownGamepad recordModel.configuredButtons

                currentButton :: remainingButton ->
                    -- Just ditch the current button
                    if remainingButton == [] then
                        configuredButtonsToOutcome recordModel.targetUnknownGamepad recordModel.configuredButtons
                    else
                        { recordModel
                            | unconfiguredButtons = remainingButton
                            , inputState = WaitingForAllButtonsUp
                        }
                            |> Ready
                            |> StillOpen


onButtonPress : Gamepad.Origin -> ModelRecord presentation -> Outcome presentation
onButtonPress origin model =
    case model.unconfiguredButtons of
        -- This should not happen, but we can recover without loss of consistency
        [] ->
            configuredButtonsToOutcome model.targetUnknownGamepad model.configuredButtons

        currentButton :: remainingButton ->
            let
                buttonConfig =
                    { destination = Tuple.first currentButton
                    , origin = origin
                    }

                configuredButtons =
                    buttonConfig :: model.configuredButtons
            in
            if remainingButton == [] then
                configuredButtonsToOutcome model.targetUnknownGamepad configuredButtons
            else
                { model
                    | configuredButtons = configuredButtons
                    , unconfiguredButtons = remainingButton
                }
                    |> Ready
                    |> StillOpen


onMaybePressedButton : Maybe Gamepad.Origin -> ModelRecord presentation -> Outcome presentation
onMaybePressedButton maybeOrigin model =
    case ( model.inputState, maybeOrigin ) of
        ( WaitingForAllButtonsUp, Just origin ) ->
            model
                |> Ready
                |> StillOpen

        ( WaitingForAllButtonsUp, Nothing ) ->
            { model | inputState = WaitingForAnyButtonDown }
                |> Ready
                |> StillOpen

        ( WaitingForAnyButtonDown, Just origin ) ->
            onButtonPress origin { model | inputState = WaitingForAllButtonsUp }

        ( WaitingForAnyButtonDown, Nothing ) ->
            model
                |> Ready
                |> StillOpen


{-| -}
update : Msg -> Model presentation -> Outcome presentation
update msg unionModel =
    case msg of
        OnGamepad ( dt, blob ) ->
            case unionModel of
                WaitingForGamepad index unconfiguredButtons ->
                    actuallyInit blob index unconfiguredButtons

                Ready model ->
                    -- fetch the new state of the target gamepad
                    case indexToUnknownGamepad blob (Gamepad.unknownGetIndex model.targetUnknownGamepad) of
                        Nothing ->
                            notConnectedError (Gamepad.unknownGetIndex model.targetUnknownGamepad)

                        Just targetUnknownGamepad ->
                            onMaybePressedButton (Gamepad.estimateOrigin targetUnknownGamepad) { model | targetUnknownGamepad = targetUnknownGamepad }



-- view


{-| Returns the index of the gamepad that's being reconfigured.
-}
getTargetGamepadIndex : Model presentation -> Int
getTargetGamepadIndex unionModel =
    case unionModel of
        Ready recordModel ->
            Gamepad.unknownGetIndex recordModel.targetUnknownGamepad

        WaitingForGamepad gamepadIndex buttonsToConfigure ->
            gamepadIndex


{-| Returns the `presentation` of the input that the tool is currently
waiting for.
You have to use this instead of `view` if your presentation type is not String.
-}
getCurrentButton : Model presentation -> Maybe presentation
getCurrentButton unionModel =
    case unionModel of
        Ready recordModel ->
            List.head recordModel.unconfiguredButtons |> Maybe.map Tuple.second

        WaitingForGamepad gamepadIndex buttonsToConfigure ->
            Nothing


{-| You can use this only if your presentation type is `String`.
It will return the presentation corresponding to the input that the
tool is currently waiting for.

If you want to use a presentation type different than String, you should use
`getCurrentButton` instead.

-}
view : Model String -> String
view model =
    getCurrentButton model |> Maybe.withDefault ""



-- subscriptions


{-| This is the type that the gamepad port should have.
It matches the one you will find in [port/GamepadPort.elm](https://github.com/xarvh/elm-gamepad/blob/master/port/GamepadPort.elm)
-}
type alias PortSubscription msg =
    (( Float, Gamepad.Blob ) -> msg) -> Sub msg


{-| -}
subscriptions : PortSubscription Msg -> Sub Msg
subscriptions portSubscription =
    portSubscription OnGamepad
