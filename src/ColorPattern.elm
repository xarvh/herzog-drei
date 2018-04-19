module ColorPattern exposing (..)


type alias ColorPattern =
    { bright : String
    , dark : String
    , key : String
    }


patterns : List ColorPattern
patterns =
    [ { bright = "#f00", dark = "#900", key = "red" }
    , { bright = "orange", dark = "blue", key = "sol" }
    , { bright = "#0f0", dark = "#090", key = "green" }
    , { bright = "#00f", dark = "#009", key = "blue" }
    , { bright = "#0ee", dark = "#0bb", key = "cyan" }
    , { bright = "#f0f", dark = "#909", key = "purple" }
    , { bright = "#ee0", dark = "#bb0", key = "yellow" }
    , { bright = "#0ee", dark = "purple", key = "octarine" }
    ]


neutral : ColorPattern
neutral =
    { bright = "#bbb", dark = "#999", key = "grey" }
