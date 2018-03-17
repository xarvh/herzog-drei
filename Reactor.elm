module Reactor exposing (..)

import Html
import Main


defaultFlags : Main.Flags
defaultFlags =
    { gamepadDatabaseAsString = ""
    , gamepadDatabaseKey = ""
    , dateNow = 1521270287621
    }


main =
    Html.program
        { init = Main.init defaultFlags
        , update = Main.update
        , view = Main.view
        , subscriptions = Main.subscriptions
        }
