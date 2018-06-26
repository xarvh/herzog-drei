module Shell exposing (..)

import Config exposing (Config)
import Dict exposing (Dict)
import Set exposing (Set)
import SplitScreen exposing (Viewport)


type alias Flags =
    { config : String
    , customMaps : String
    , dateNow : Int
    , mapEditorCurrentMap : String
    , windowWidth : Int
    , windowHeight : Int
    }


type alias Shell =
    { gameIsPaused : Bool
    , mousePosition : { x : Int, y : Int }
    , mouseIsPressed : Bool
    , windowSize : WindowSize
    , viewport : Viewport
    , params : Dict String String
    , pressedKeys : Set String
    , config : Config
    , flags : Flags
    }


type alias WindowSize =
    { width : Int
    , height : Int
    }
