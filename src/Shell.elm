module Shell exposing (..)

import Config exposing (Config)
import Dict exposing (Dict)
import Keyboard.Extra
import Mouse
import SplitScreen exposing (Viewport)
import Window


type alias Flags =
    { configAsString : String
    , configKey : String
    , dateNow : Int
    }


type alias Shell =
    { gameIsPaused : Bool
    , mousePosition : Mouse.Position
    , mouseIsPressed : Bool
    , windowSize : Window.Size
    , viewport : Viewport
    , params : Dict String String
    , pressedKeys : List Keyboard.Extra.Key
    , config : Config
    , flags : Flags
    }
