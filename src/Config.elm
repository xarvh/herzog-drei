module Config exposing (..)

import Gamepad
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias Config =
    { gamepadDatabase : Gamepad.UserMappings
    , useKeyboardAndMouse : Bool
    , showFps : Bool
    }


default : Config
default =
    { gamepadDatabase = Gamepad.emptyUserMappings
    , useKeyboardAndMouse = True
    , showFps = False
    }



-- Decoder


withDefault : a -> Decoder a -> Decoder a
withDefault value dec =
    Decode.maybe dec |> Decode.map (Maybe.withDefault value)


decoder : Decoder Config
decoder =
    Decode.map3 Config
        (Decode.field "gamepadDatabase" Gamepad.userMappingsDecoder |> withDefault default.gamepadDatabase)
        (Decode.field "useKeyboardAndMouse" Decode.bool |> withDefault default.useKeyboardAndMouse)
        (Decode.field "showFps" Decode.bool |> withDefault default.showFps)


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
        [ ( "gamepadDatabase", Gamepad.encodeUserMappings config.gamepadDatabase )
        , ( "useKeyboardAndMouse", Encode.bool config.useKeyboardAndMouse )
        , ( "showFps", Encode.bool config.showFps )
        ]


toString : Config -> String
toString config =
    Encode.encode 0 (encoder config)
