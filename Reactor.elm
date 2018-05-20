module Reactor exposing (..)

import Main
import Navigation


defaultFlags : Main.Flags
defaultFlags =
    { gamepadDatabaseAsString = ""
    , gamepadDatabaseKey = ""
    , dateNow = 1521270287621
    }


main =
    Navigation.program
        (always Main.Noop)
        { init = Main.init defaultFlags
        , update = Main.update
        , view = Main.view
        , subscriptions = Main.subscriptions
        }
