module Config exposing (..)

import Gamepad
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Config =
    { gamepadDatabase : Gamepad.Database
    , useKeyboardAndMouse : Bool
    }


default : Config
default =
    { gamepadDatabase = Gamepad.emptyDatabase
    , useKeyboardAndMouse = True
    }



-- Decoder


withDefault : a -> Decoder a -> Decoder a
withDefault value dec =
    Decode.maybe dec |> Decode.map (Maybe.withDefault value)


gamepadDatabaseDecoder : Decoder Gamepad.Database
gamepadDatabaseDecoder =
    Decode.string
        |> Decode.andThen
            (\asString ->
                case Gamepad.databaseFromString asString of
                    Err message ->
                        Decode.fail message

                    Ok db ->
                        Decode.succeed db
            )


decoder : Decoder Config
decoder =
    Decode.map2 Config
        (Decode.field "gamepadDatabase" gamepadDatabaseDecoder |> withDefault default.gamepadDatabase)
        (Decode.field "useKeyboardAndMouse" Decode.bool |> withDefault default.useKeyboardAndMouse)


fromString : String -> Config
fromString s =
    case Decode.decodeString decoder s of
        Ok config ->
            config

        Err message ->
            default



-- Encoder


encoder : Config -> Encode.Value
encoder config =
    Encode.object
        [ ( "gamepadDatabase", Encode.string (Gamepad.databaseToString config.gamepadDatabase) )
        , ( "useKeyboardAndMouse", Encode.bool config.useKeyboardAndMouse )
        ]


toString : Config -> String
toString config =
    Encode.encode 0 (encoder config)
