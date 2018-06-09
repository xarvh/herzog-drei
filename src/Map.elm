module Map exposing (..)

import Dict exposing (Dict)
import Game exposing (..)
import Json.Decode as Decode exposing (Decoder, field)
import Json.Encode as Encode exposing (Value)
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


toGame : Map -> Game -> Game
toGame map game =
    -- TODO
    game



-- Map <=> Json


tileEncoder : Tile2 -> Value
tileEncoder ( x, y ) =
    Encode.list [ Encode.int x, Encode.int x ]


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
        , ( "auhtor", Encode.string map.author )
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
                                                                                            , halfHeight = halfWidth
                                                                                            , halfWidth = halfHeight
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
