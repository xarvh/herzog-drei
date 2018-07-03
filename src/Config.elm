module Config exposing (..)

import Dict exposing (Dict)
import Gamepad
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Config =
    { gamepadDatabase : Gamepad.Database
    , useKeyboardAndMouse : Bool
    , showFps : Bool
    , params : Dict String String
    }


default : Config
default =
    { gamepadDatabase = Gamepad.emptyDatabase
    , useKeyboardAndMouse = True
    , showFps = False
    , params = Dict.empty
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
    Decode.map4 Config
        (Decode.field "gamepadDatabase" gamepadDatabaseDecoder |> withDefault default.gamepadDatabase)
        (Decode.field "useKeyboardAndMouse" Decode.bool |> withDefault default.useKeyboardAndMouse)
        (Decode.field "showFps" Decode.bool |> withDefault default.showFps)
        (Decode.field "params" (Decode.dict Decode.string) |> withDefault default.params)


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
        , ( "showFps", Encode.bool config.showFps )
        , ( "params", Encode.dict identity Encode.string config.params)
        ]


toString : Config -> String
toString config =
    Encode.encode 0 (encoder config)
