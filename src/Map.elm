module Map exposing (..)

import Base
import Dict exposing (Dict)
import Game exposing (..)
import Json.Decode as Decode exposing (Decoder, field)
import Json.Encode as Encode exposing (Value)
import List.Extra
import Set exposing (Set)


minSize : Int
minSize =
    8


maxSize : Int
maxSize =
    30


type alias Map =
    { name : String
    , author : String
    , halfWidth : Int
    , halfHeight : Int
    , mainBases : List Tile2
    , smallBases : List Tile2
    , wallTiles : List Tile2
    }



-- Validation


validate : Map -> Result String ValidatedMap
validate map =
    let
        hw =
            clamp minSize maxSize map.halfWidth

        hh =
            clamp minSize maxSize map.halfHeight

        isWithin : Tile2 -> Bool
        isWithin ( x, y ) =
            x >= -hw && x < hw && y >= -hh && y < hh

        allTiles : List Tile2
        allTiles =
            [ List.map (Base.tiles BaseMain) map.mainBases |> List.concat
            , List.map (Base.tiles BaseSmall) map.smallBases |> List.concat
            , map.wallTiles
            ]
                |> List.concat

        outOfBounds : List Tile2
        outOfBounds =
            List.filter (\t -> not <| isWithin t) allTiles

        dictIncrement : Tile2 -> Dict Tile2 Int -> Dict Tile2 Int
        dictIncrement key =
            Dict.update key (Maybe.withDefault 0 >> (+) 1 >> Just)

        overlaps : List Tile2
        overlaps =
            allTiles
                |> List.Extra.unique
                |> List.map (\tile -> ( tile, 0 ))
                |> Dict.fromList
                |> (\d -> List.foldl dictIncrement d allTiles)
                |> Dict.filter (\k v -> v > 1)
                |> Dict.keys

        tilesToString : List Tile2 -> String
        tilesToString tiles =
            tiles |> List.map Basics.toString |> String.join ", "
    in
    if outOfBounds /= [] then
        outOfBounds |> tilesToString |> (++) "Tiles out of bounds: " |> Err
    else if overlaps /= [] then
        overlaps |> tilesToString |> (++) "Overlapping tiles: " |> Err
    else
        case map.mainBases of
            [] ->
                Err "No main bases"

            a :: [] ->
                Err "Only 1 main base"

            a :: b :: c :: _ ->
                Err "Too many main bases"

            [ left, right ] ->
                Ok
                    { halfWidth = hw
                    , halfHeight = hh
                    , leftBase = left
                    , rightBase = right
                    , smallBases = Set.fromList map.smallBases
                    , wallTiles = Set.fromList map.wallTiles
                    }



-- Map <=> Game


fromGame : String -> String -> Game -> Map
fromGame name author game =
    let
        bases baseType =
            game.baseById
                |> Dict.values
                |> List.filter (\b -> b.type_ == baseType)
                |> List.map .tile
    in
    { name = name
    , author = author
    , halfWidth = game.halfWidth
    , halfHeight = game.halfHeight
    , mainBases = bases BaseMain |> List.sort
    , smallBases = bases BaseSmall |> List.sort
    , wallTiles = Set.toList game.wallTiles |> List.sort
    }


addBases : BaseType -> List Tile2 -> Game -> Game
addBases baseType tiles game =
    List.foldl (\tile g -> Base.add baseType tile g |> Tuple.first) game tiles


toGame : Map -> Game -> Game
toGame map game =
    { game
        | halfWidth = map.halfWidth
        , halfHeight = map.halfHeight
        , wallTiles = Set.fromList map.wallTiles
    }
        |> addBases BaseMain map.mainBases
        |> addBases BaseSmall map.smallBases



-- Map <=> Json


tileEncoder : Tile2 -> Value
tileEncoder ( x, y ) =
    Encode.list [ Encode.int x, Encode.int y ]


tileDecoder : Decoder Tile2
tileDecoder =
    Decode.list Decode.int
        |> Decode.andThen
            (\list ->
                case list of
                    [ x, y ] ->
                        Decode.succeed ( x, y )

                    _ ->
                        Decode.fail "Tile2 must be of length 2"
            )


listOfTilesEncoder : List Tile2 -> Value
listOfTilesEncoder tiles =
    tiles |> List.map tileEncoder |> Encode.list


listOfTilesDecoder : Decoder (List Tile2)
listOfTilesDecoder =
    Decode.list tileDecoder


mapEncoder : Map -> Value
mapEncoder map =
    Encode.object
        [ ( "name", Encode.string map.name )
        , ( "author", Encode.string map.author )
        , ( "halfWidth", Encode.int map.halfWidth )
        , ( "halfHeight", Encode.int map.halfHeight )
        , ( "mainBases", listOfTilesEncoder map.mainBases )
        , ( "smallBases", listOfTilesEncoder map.smallBases )
        , ( "wallTiles", listOfTilesEncoder map.wallTiles )
        ]


toString : Map -> String
toString map =
    Encode.encode 0 (mapEncoder map)


mapDecoder : Decoder Map
mapDecoder =
    (field "name" <| Decode.string)
        |> Decode.andThen
            (\name ->
                (field "author" <| Decode.string)
                    |> Decode.andThen
                        (\author ->
                            (field "halfWidth" <| Decode.int)
                                |> Decode.andThen
                                    (\halfWidth ->
                                        (field "halfHeight" <| Decode.int)
                                            |> Decode.andThen
                                                (\halfHeight ->
                                                    (field "mainBases" <| listOfTilesDecoder)
                                                        |> Decode.andThen
                                                            (\mainBases ->
                                                                (field "smallBases" <| listOfTilesDecoder)
                                                                    |> Decode.andThen
                                                                        (\smallBases ->
                                                                            (field "wallTiles" <| listOfTilesDecoder)
                                                                                |> Decode.andThen
                                                                                    (\wallTiles ->
                                                                                        Decode.succeed
                                                                                            { name = name
                                                                                            , author = author
                                                                                            , halfWidth = halfWidth
                                                                                            , halfHeight = halfHeight
                                                                                            , mainBases = mainBases
                                                                                            , smallBases = smallBases
                                                                                            , wallTiles = wallTiles
                                                                                            }
                                                                                    )
                                                                        )
                                                            )
                                                )
                                    )
                        )
            )


fromString : String -> Result String Map
fromString json =
    Decode.decodeString mapDecoder json
