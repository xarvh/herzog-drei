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
    , bases : Dict Tile2 BaseType
    , wallTiles : Set Tile2
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
            [ map.wallTiles |> Set.toList
            , map.bases
                |> Dict.map (\tile baseType -> Base.tiles baseType tile)
                |> Dict.values
                |> List.concat
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

        bases : BaseType -> List Tile2
        bases baseType =
            map.bases
                |> Dict.filter (\tile t -> t == baseType)
                |> Dict.keys
                |> List.sort
    in
    if outOfBounds /= [] then
        outOfBounds |> tilesToString |> (++) "Tiles out of bounds: " |> Err
    else if overlaps /= [] then
        overlaps |> tilesToString |> (++) "Overlapping tiles: " |> Err
    else
        case bases BaseMain of
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
                    , smallBases = bases BaseSmall |> Set.fromList
                    , wallTiles = map.wallTiles
                    }



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


setOfTilesEncoder : Set Tile2 -> Value
setOfTilesEncoder tiles =
    tiles |> Set.toList |> List.map tileEncoder |> Encode.list


setOfTilesDecoder : Decoder (Set Tile2)
setOfTilesDecoder =
    Decode.list tileDecoder |> Decode.map Set.fromList


encodeBases : BaseType -> Map -> Value
encodeBases baseType map =
    map.bases
        |> Dict.filter (\tile type_ -> type_ == BaseMain)
        |> Dict.keys
        |> List.map tileEncoder
        |> Encode.list


mapEncoder : Map -> Value
mapEncoder map =
    Encode.object
        [ ( "name", Encode.string map.name )
        , ( "author", Encode.string map.author )
        , ( "halfWidth", Encode.int map.halfWidth )
        , ( "halfHeight", Encode.int map.halfHeight )
        , ( "mainBases", encodeBases BaseMain map )
        , ( "smallBases", encodeBases BaseSmall map )
        , ( "wallTiles", setOfTilesEncoder map.wallTiles )
        ]


toString : Map -> String
toString map =
    Encode.encode 0 (mapEncoder map)



{-
   https://github.com/avh4/elm-format/issues/352   =****(

   (&>) = flip Decode.andThen

   mapDecoder : Decoder Map
   mapDecoder =
       field "name" Decode.string &> \name ->
       field "author" Decode.string &> \author ->
       field "halfWidth" Decode.int &> \halfWidth ->
       field "halfHeight" Decode.int &> \halfHeight ->
       field "mainBases" setOfTilesDecoder &> \mainBases ->
       field "smallBases" setOfTilesDecoder &> \smallBases ->
       field "wallTiles" setOfTilesDecoder &> \wallTiles ->
         Decode.succeed
             { name = name
             , author = author
             , halfWidth = halfWidth
             , halfHeight = halfHeight
             , mainBases = mainBases
             , smallBases = smallBases
             , wallTiles = wallTiles
             }

-}


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
                                                    (field "mainBases" <| Decode.list tileDecoder)
                                                        |> Decode.andThen
                                                            (\mainBases ->
                                                                (field "smallBases" <| Decode.list tileDecoder)
                                                                    |> Decode.andThen
                                                                        (\smallBases ->
                                                                            (field "wallTiles" <| setOfTilesDecoder)
                                                                                |> Decode.andThen
                                                                                    (\wallTiles ->
                                                                                        Decode.succeed
                                                                                            { name = name
                                                                                            , author = author
                                                                                            , halfWidth = halfWidth
                                                                                            , halfHeight = halfHeight
                                                                                            , wallTiles = wallTiles
                                                                                            , bases =
                                                                                                [ mainBases |> List.map (\tile -> ( tile, BaseMain ))
                                                                                                , smallBases |> List.map (\tile -> ( tile, BaseSmall ))
                                                                                                ]
                                                                                                    |> List.concat
                                                                                                    |> Dict.fromList
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
