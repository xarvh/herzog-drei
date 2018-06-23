module OfficialMaps exposing (..)

import Game exposing (ValidatedMap)
import Set exposing (Set)


default : ValidatedMap
default =
    { name = "Default map"
    , author = ""
    , halfWidth = 20
    , halfHeight = 10
    , leftBase = ( -15, 0 )
    , rightBase = ( 15, 0 )
    , smallBases = Set.fromList [ ( 0, -7 ), ( 0, 7 ) ]
    , wallTiles = Set.empty
    }


maps : List ValidatedMap
maps =
    [ { name = "Loveledge"
      , author = "xa"
      , halfWidth = 20
      , halfHeight = 10
      , leftBase = ( -17, 7 )
      , rightBase = ( 17, -7 )
      , smallBases = Set.fromList [ ( 5, 3 ), ( -5, -3 ) ]
      , wallTiles = Set.fromList [ ( -16, -8 ), ( -16, -7 ), ( -16, -6 ), ( -16, -5 ), ( -16, -4 ), ( -15, -8 ), ( -15, -7 ), ( -14, 3 ), ( -14, 4 ), ( -12, 0 ), ( -11, 1 ), ( -11, 2 ), ( -11, 3 ), ( -10, -2 ), ( -10, -1 ), ( -10, 3 ), ( -10, 4 ), ( -10, 5 ), ( -10, 6 ), ( -10, 7 ), ( -6, 2 ), ( -5, -7 ), ( -5, -6 ), ( -2, 0 ), ( -1, 5 ), ( 0, -6 ), ( 1, -1 ), ( 4, 5 ), ( 4, 6 ), ( 5, -3 ), ( 9, -8 ), ( 9, -7 ), ( 9, -6 ), ( 9, -5 ), ( 9, -4 ), ( 9, 0 ), ( 9, 1 ), ( 10, -4 ), ( 10, -3 ), ( 10, -2 ), ( 11, -1 ), ( 13, -5 ), ( 13, -4 ), ( 14, 6 ), ( 14, 7 ), ( 15, 3 ), ( 15, 4 ), ( 15, 5 ), ( 15, 6 ), ( 15, 7 ) ]
      }
    , { name = "Eight Shells"
      , author = "dd"
      , halfWidth = 20
      , halfHeight = 10
      , leftBase = ( -15, 1 )
      , rightBase = ( 15, -1 )
      , smallBases = Set.fromList [ ( -8, -7 ), ( -7, 7 ), ( -1, -8 ), ( 1, 8 ), ( 7, -7 ), ( 8, 7 ) ]
      , wallTiles = Set.fromList [ ( -20, -10 ), ( -20, -6 ), ( -20, -4 ), ( -20, -3 ), ( -20, -2 ), ( -20, -1 ), ( -20, 0 ), ( -20, 1 ), ( -20, 2 ), ( -20, 3 ), ( -20, 4 ), ( -20, 7 ), ( -20, 9 ), ( -19, -8 ), ( -19, -4 ), ( -19, -3 ), ( -19, 4 ), ( -19, 6 ), ( -18, -10 ), ( -18, -7 ), ( -18, -5 ), ( -18, -4 ), ( -18, -3 ), ( -18, 4 ), ( -18, 5 ), ( -18, 7 ), ( -18, 9 ), ( -17, -10 ), ( -17, -8 ), ( -17, -5 ), ( -17, -4 ), ( -17, -3 ), ( -17, 4 ), ( -17, 5 ), ( -16, 5 ), ( -15, -10 ), ( -14, -10 ), ( -14, -9 ), ( -14, -5 ), ( -14, -4 ), ( -13, -10 ), ( -13, -9 ), ( -13, -5 ), ( -13, -4 ), ( -13, 5 ), ( -13, 8 ), ( -13, 9 ), ( -12, -10 ), ( -12, -9 ), ( -12, -5 ), ( -12, -4 ), ( -12, -3 ), ( -12, 4 ), ( -12, 5 ), ( -12, 8 ), ( -12, 9 ), ( -11, -4 ), ( -11, -3 ), ( -11, -2 ), ( -11, 2 ), ( -11, 3 ), ( -11, 4 ), ( -11, 5 ), ( -11, 8 ), ( -11, 9 ), ( -10, -3 ), ( -10, -2 ), ( -10, 2 ), ( -10, 3 ), ( -9, -3 ), ( -9, -2 ), ( -8, 2 ), ( -8, 3 ), ( -7, 2 ), ( -7, 3 ), ( -6, -3 ), ( -6, -2 ), ( -5, -10 ), ( -5, -9 ), ( -5, -8 ), ( -5, -7 ), ( -5, -6 ), ( -5, -3 ), ( -5, -2 ), ( -5, 2 ), ( -5, 3 ), ( -4, -10 ), ( -4, -9 ), ( -4, -8 ), ( -4, -7 ), ( -4, -6 ), ( -4, -3 ), ( -4, -2 ), ( -4, 2 ), ( -4, 3 ), ( -4, 4 ), ( -4, 5 ), ( -4, 6 ), ( -4, 7 ), ( -4, 8 ), ( -4, 9 ), ( -3, 2 ), ( -3, 3 ), ( -3, 4 ), ( -3, 5 ), ( -3, 6 ), ( -3, 7 ), ( -3, 8 ), ( -3, 9 ), ( 2, -10 ), ( 2, -9 ), ( 2, -8 ), ( 2, -7 ), ( 2, -6 ), ( 2, -5 ), ( 2, -4 ), ( 2, -3 ), ( 3, -10 ), ( 3, -9 ), ( 3, -8 ), ( 3, -7 ), ( 3, -6 ), ( 3, -5 ), ( 3, -4 ), ( 3, -3 ), ( 3, 1 ), ( 3, 2 ), ( 3, 5 ), ( 3, 6 ), ( 3, 7 ), ( 3, 8 ), ( 3, 9 ), ( 4, -4 ), ( 4, -3 ), ( 4, 1 ), ( 4, 2 ), ( 4, 5 ), ( 4, 6 ), ( 4, 7 ), ( 4, 8 ), ( 4, 9 ), ( 5, 1 ), ( 5, 2 ), ( 6, -4 ), ( 6, -3 ), ( 7, -4 ), ( 7, -3 ), ( 8, 1 ), ( 8, 2 ), ( 9, -4 ), ( 9, -3 ), ( 9, 1 ), ( 9, 2 ), ( 10, -10 ), ( 10, -9 ), ( 10, -6 ), ( 10, -5 ), ( 10, -4 ), ( 10, -3 ), ( 10, 1 ), ( 10, 2 ), ( 10, 3 ), ( 11, -10 ), ( 11, -9 ), ( 11, -6 ), ( 11, -5 ), ( 11, 2 ), ( 11, 3 ), ( 11, 4 ), ( 11, 8 ), ( 11, 9 ), ( 12, -10 ), ( 12, -9 ), ( 12, -6 ), ( 12, 3 ), ( 12, 4 ), ( 12, 8 ), ( 12, 9 ), ( 13, 3 ), ( 13, 4 ), ( 13, 8 ), ( 13, 9 ), ( 14, 9 ), ( 15, -6 ), ( 16, -6 ), ( 16, -5 ), ( 16, 2 ), ( 16, 3 ), ( 16, 4 ), ( 16, 7 ), ( 16, 9 ), ( 17, -10 ), ( 17, -8 ), ( 17, -6 ), ( 17, -5 ), ( 17, 2 ), ( 17, 3 ), ( 17, 4 ), ( 17, 6 ), ( 17, 9 ), ( 18, -7 ), ( 18, -5 ), ( 18, 2 ), ( 18, 3 ), ( 18, 7 ), ( 19, -10 ), ( 19, -8 ), ( 19, -5 ), ( 19, -4 ), ( 19, -3 ), ( 19, -2 ), ( 19, -1 ), ( 19, 0 ), ( 19, 1 ), ( 19, 2 ), ( 19, 3 ), ( 19, 5 ), ( 19, 9 ) ]
      }
    , { name = "Doubt Thyself"
      , author = "JT"
      , halfWidth = 20
      , halfHeight = 10
      , leftBase = ( -15, -7 )
      , rightBase = ( 15, 7 )
      , smallBases = Set.fromList [ ( -16, -2 ), ( -16, 6 ), ( -8, -3 ), ( -8, 3 ), ( -5, -8 ), ( 5, 8 ), ( 8, -3 ), ( 8, 3 ), ( 16, -6 ), ( 16, 2 ) ]
      , wallTiles = Set.fromList [ ( -20, -10 ), ( -20, -8 ), ( -20, -5 ), ( -19, -10 ), ( -19, -9 ), ( -19, -7 ), ( -13, -5 ), ( -11, -5 ), ( -7, 7 ), ( -7, 8 ), ( -6, 7 ), ( -6, 9 ), ( -5, -2 ), ( -3, -4 ), ( -3, -2 ), ( -3, -1 ), ( -3, 0 ), ( -2, 0 ), ( -2, 1 ), ( -1, -5 ), ( -1, -2 ), ( -1, 0 ), ( -1, 2 ), ( 0, -3 ), ( 0, -1 ), ( 0, 1 ), ( 0, 4 ), ( 1, -2 ), ( 1, -1 ), ( 2, -4 ), ( 2, -1 ), ( 2, 1 ), ( 4, 1 ), ( 5, -10 ), ( 5, -8 ), ( 6, -9 ), ( 6, -8 ), ( 10, 4 ), ( 12, 4 ), ( 18, 6 ), ( 18, 8 ), ( 18, 9 ), ( 19, 4 ), ( 19, 7 ), ( 19, 9 ) ]
      }
    , { name = "Dikjistra's Spiral"
      , author = "NA"
      , halfWidth = 24
      , halfHeight = 15
      , leftBase = ( -21, 9 )
      , rightBase = ( 21, -9 )
      , smallBases = Set.fromList [ ( -19, -11 ), ( -10, -3 ), ( -2, 6 ), ( 0, 0 ), ( 2, -6 ), ( 10, 3 ), ( 19, 11 ) ]
      , wallTiles = Set.fromList [ ( -25, 1 ), ( -24, -14 ), ( -24, -13 ), ( -24, -12 ), ( -24, -11 ), ( -24, -10 ), ( -24, -7 ), ( -24, -6 ), ( -24, -5 ), ( -24, -4 ), ( -24, -3 ), ( -24, -2 ), ( -24, -1 ), ( -24, 0 ), ( -24, 1 ), ( -24, 2 ), ( -24, 3 ), ( -24, 14 ), ( -23, -12 ), ( -23, -11 ), ( -23, -10 ), ( -23, -9 ), ( -23, -6 ), ( -23, -5 ), ( -23, -4 ), ( -23, -3 ), ( -23, -1 ), ( -23, 0 ), ( -23, 1 ), ( -23, 2 ), ( -23, 3 ), ( -23, 13 ), ( -23, 14 ), ( -22, -10 ), ( -22, -9 ), ( -22, -5 ), ( -22, 0 ), ( -22, 1 ), ( -22, 2 ), ( -22, 13 ), ( -22, 14 ), ( -21, -9 ), ( -21, -8 ), ( -21, -2 ), ( -21, -1 ), ( -21, 0 ), ( -21, 1 ), ( -21, 2 ), ( -21, 14 ), ( -20, -9 ), ( -20, -8 ), ( -20, -6 ), ( -20, -3 ), ( -20, -2 ), ( -20, -1 ), ( -20, 0 ), ( -20, 2 ), ( -20, 3 ), ( -20, 13 ), ( -20, 14 ), ( -19, -9 ), ( -19, -8 ), ( -19, -7 ), ( -19, -6 ), ( -19, -3 ), ( -19, -2 ), ( -19, 3 ), ( -19, 13 ), ( -19, 14 ), ( -18, -9 ), ( -18, -8 ), ( -18, 14 ), ( -17, -9 ), ( -17, -8 ), ( -17, -7 ), ( -17, 9 ), ( -17, 10 ), ( -16, -10 ), ( -16, -9 ), ( -16, 8 ), ( -16, 9 ), ( -16, 10 ), ( -15, -11 ), ( -15, -10 ), ( -15, -9 ), ( -14, -10 ), ( -14, 4 ), ( -14, 14 ), ( -13, 3 ), ( -13, 4 ), ( -13, 14 ), ( -12, -15 ), ( -12, 3 ), ( -12, 13 ), ( -12, 14 ), ( -11, -15 ), ( -11, -14 ), ( -11, 12 ), ( -11, 13 ), ( -11, 14 ), ( -10, -15 ), ( -10, -7 ), ( -10, -6 ), ( -10, -5 ), ( -10, 9 ), ( -10, 10 ), ( -10, 11 ), ( -10, 12 ), ( -10, 13 ), ( -10, 14 ), ( -9, -15 ), ( -9, -6 ), ( -9, -5 ), ( -9, -4 ), ( -9, -3 ), ( -9, 10 ), ( -9, 11 ), ( -9, 12 ), ( -9, 13 ), ( -9, 14 ), ( -8, -5 ), ( -8, -4 ), ( -8, -3 ), ( -8, -2 ), ( -8, 11 ), ( -8, 12 ), ( -8, 13 ), ( -8, 14 ), ( -7, -4 ), ( -7, -3 ), ( -7, -2 ), ( -7, -1 ), ( -7, 5 ), ( -7, 12 ), ( -7, 13 ), ( -7, 14 ), ( -6, -13 ), ( -6, -12 ), ( -6, -11 ), ( -6, 4 ), ( -6, 5 ), ( -6, 6 ), ( -6, 13 ), ( -6, 14 ), ( -5, -14 ), ( -5, -13 ), ( -5, -12 ), ( -5, -11 ), ( -5, -10 ), ( -5, 4 ), ( -5, 5 ), ( -5, 13 ), ( -5, 14 ), ( -4, -14 ), ( -4, -13 ), ( -4, -12 ), ( -4, -11 ), ( -4, 2 ), ( -4, 3 ), ( -4, 4 ), ( -4, 5 ), ( -4, 12 ), ( -4, 13 ), ( -4, 14 ), ( -3, -13 ), ( -3, -12 ), ( -3, 2 ), ( -3, 3 ), ( -3, 4 ), ( -3, 11 ), ( -3, 12 ), ( -3, 13 ), ( -3, 14 ), ( -2, -13 ), ( -2, -12 ), ( -2, 3 ), ( -2, 4 ), ( -2, 11 ), ( -2, 12 ), ( -2, 13 ), ( -2, 14 ), ( -1, -15 ), ( -1, -12 ), ( -1, -6 ), ( -1, -5 ), ( -1, -4 ), ( -1, 4 ), ( -1, 5 ), ( -1, 11 ), ( -1, 12 ), ( -1, 13 ), ( -1, 14 ), ( 0, -15 ), ( 0, -14 ), ( 0, -13 ), ( 0, -12 ), ( 0, -6 ), ( 0, -5 ), ( 0, 3 ), ( 0, 4 ), ( 0, 5 ), ( 0, 11 ), ( 0, 14 ), ( 1, -15 ), ( 1, -14 ), ( 1, -13 ), ( 1, -12 ), ( 1, -5 ), ( 1, -4 ), ( 1, 11 ), ( 1, 12 ), ( 2, -15 ), ( 2, -14 ), ( 2, -13 ), ( 2, -12 ), ( 2, -5 ), ( 2, -4 ), ( 2, -3 ), ( 2, 11 ), ( 2, 12 ), ( 3, -15 ), ( 3, -14 ), ( 3, -13 ), ( 3, -6 ), ( 3, -5 ), ( 3, -4 ), ( 3, -3 ), ( 3, 10 ), ( 3, 11 ), ( 3, 12 ), ( 3, 13 ), ( 4, -15 ), ( 4, -14 ), ( 4, -6 ), ( 4, -5 ), ( 4, 9 ), ( 4, 10 ), ( 4, 11 ), ( 4, 12 ), ( 4, 13 ), ( 5, -15 ), ( 5, -14 ), ( 5, -7 ), ( 5, -6 ), ( 5, -5 ), ( 5, 10 ), ( 5, 11 ), ( 5, 12 ), ( 6, -15 ), ( 6, -14 ), ( 6, -13 ), ( 6, -6 ), ( 6, 0 ), ( 6, 1 ), ( 6, 2 ), ( 6, 3 ), ( 7, -15 ), ( 7, -14 ), ( 7, -13 ), ( 7, -12 ), ( 7, 1 ), ( 7, 2 ), ( 7, 3 ), ( 7, 4 ), ( 8, -15 ), ( 8, -14 ), ( 8, -13 ), ( 8, -12 ), ( 8, -11 ), ( 8, 2 ), ( 8, 3 ), ( 8, 4 ), ( 8, 5 ), ( 8, 14 ), ( 9, -15 ), ( 9, -14 ), ( 9, -13 ), ( 9, -12 ), ( 9, -11 ), ( 9, -10 ), ( 9, 4 ), ( 9, 5 ), ( 9, 6 ), ( 9, 14 ), ( 10, -15 ), ( 10, -14 ), ( 10, -13 ), ( 10, 13 ), ( 10, 14 ), ( 11, -15 ), ( 11, -14 ), ( 11, -4 ), ( 11, 14 ), ( 12, -15 ), ( 12, -5 ), ( 12, -4 ), ( 13, -15 ), ( 13, -5 ), ( 13, 9 ), ( 14, 8 ), ( 14, 9 ), ( 14, 10 ), ( 15, -11 ), ( 15, -10 ), ( 15, -9 ), ( 15, 8 ), ( 15, 9 ), ( 16, -11 ), ( 16, -10 ), ( 16, 6 ), ( 16, 7 ), ( 16, 8 ), ( 17, -15 ), ( 17, 7 ), ( 17, 8 ), ( 18, -15 ), ( 18, -14 ), ( 18, -4 ), ( 18, 1 ), ( 18, 2 ), ( 18, 5 ), ( 18, 6 ), ( 18, 7 ), ( 18, 8 ), ( 19, -15 ), ( 19, -14 ), ( 19, -4 ), ( 19, -3 ), ( 19, -1 ), ( 19, 0 ), ( 19, 1 ), ( 19, 2 ), ( 19, 5 ), ( 19, 7 ), ( 19, 8 ), ( 20, -15 ), ( 20, -3 ), ( 20, -2 ), ( 20, -1 ), ( 20, 0 ), ( 20, 1 ), ( 20, 7 ), ( 20, 8 ), ( 21, -15 ), ( 21, -14 ), ( 21, -3 ), ( 21, -2 ), ( 21, -1 ), ( 21, 4 ), ( 21, 8 ), ( 21, 9 ), ( 22, -15 ), ( 22, -14 ), ( 22, -4 ), ( 22, -3 ), ( 22, -2 ), ( 22, -1 ), ( 22, 0 ), ( 22, 2 ), ( 22, 3 ), ( 22, 4 ), ( 22, 5 ), ( 22, 8 ), ( 22, 9 ), ( 22, 10 ), ( 22, 11 ), ( 23, -15 ), ( 23, -4 ), ( 23, -3 ), ( 23, -2 ), ( 23, -1 ), ( 23, 0 ), ( 23, 1 ), ( 23, 2 ), ( 23, 3 ), ( 23, 4 ), ( 23, 5 ), ( 23, 6 ), ( 23, 9 ), ( 23, 10 ), ( 23, 11 ), ( 23, 12 ), ( 23, 13 ), ( 24, -2 ) ]
      }
    ]