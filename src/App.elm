module App exposing (..)

import AStar
import AnimationFrame
import Dict exposing (Dict)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Mouse
import Set exposing (Set)
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Time exposing (Time)


--


type alias TilePosition =
    AStar.Position



-- Helpers


clampToRadius : Float -> Vec2 -> Vec2
clampToRadius radius v =
    let
        ll =
            Vec2.lengthSquared v
    in
    if ll <= radius * radius then
        v
    else
        Vec2.scale (radius / sqrt ll) v


vec2Tile : Vec2 -> TilePosition
vec2Tile v =
    let
        ( x, y ) =
            Vec2.toTuple v
    in
    ( floor x, floor y )


tile2Vec : TilePosition -> Vec2
tile2Vec ( x, y ) =
    vec2 (toFloat x) (toFloat y)



-- Bases


type alias Base =
    { id : Id
    , containedUnits : Int
    , position : Vec2
    }


addBase : Id -> Vec2 -> Dict Id Base -> Dict Id Base
addBase id position =
    Dict.insert id (Base id 0 position)



-- Units


type alias Unit =
    { id : Id
    , position : Vec2
    }


addUnit : Id -> Vec2 -> Dict Id Unit -> Dict Id Unit
addUnit id position =
    Dict.insert id (Unit id position)


getAvailableMoves : Set TilePosition -> TilePosition -> Set TilePosition
getAvailableMoves occupiedPositions ( x, y ) =
    [ if x > -5 then
        [ ( x - 1, y ) ]
      else
        []
    , if x < 4 then
        [ ( x + 1, y ) ]
      else
        []
    , if y > -5 then
        [ ( x, y - 1 ) ]
      else
        []
    , if y < 4 then
        [ ( x, y + 1 ) ]
      else
        []
    ]
        |> List.concat
        |> List.filter (\pos -> not <| Set.member pos occupiedPositions)
        |> Set.fromList


unitThink : Float -> Game -> Unit -> Maybe Delta
unitThink dt game unit =
    let
        targetDistance =
            0

        unitTile =
            vec2Tile unit.position

        targetTile =
            vec2Tile game.target
    in
    if AStar.straightLineCost unitTile targetTile <= targetDistance then
        Nothing
    else
        let
            path =
                AStar.findPath
                    AStar.straightLineCost
                    (getAvailableMoves game.unpassableTiles)
                    unitTile
                    targetTile
                    targetDistance

            idealDelta =
                case path of
                    [] ->
                        Vec2.sub game.target unit.position

                    head :: tail ->
                        Vec2.sub (tile2Vec head) (tile2Vec unitTile)

            speed =
                1

            maxLength =
                speed * dt / 1000

            viableDelta =
                clampToRadius maxLength idealDelta

            newPosition =
                Vec2.add unit.position viableDelta
        in
        Just (MoveUnit unit.id newPosition)



-- Game


type alias Id =
    Int


type Delta
    = MoveUnit Id Vec2
    | UnitEntersBase Id Id


type alias Game =
    { baseById : Dict Id Base
    , unitById : Dict Id Unit
    , target : Vec2

    -- includes terrain and bases
    , staticObstacles : Set TilePosition

    -- this is the union between static obstacles and unit positions
    , unpassableTiles : Set TilePosition
    }


updateGame : Float -> Game -> Game
updateGame dt oldGame =
    let
        units =
            Dict.values oldGame.unitById

        updatedUnpassableTiles =
            units
                |> List.map (.position >> vec2Tile)
                |> Set.fromList
                |> Set.union oldGame.staticObstacles

        oldGameWithUpdatedUnpassableTiles =
            { oldGame | unpassableTiles = updatedUnpassableTiles }
    in
    List.concat
        [ List.filterMap (unitThink dt oldGameWithUpdatedUnpassableTiles) units
        ]
        |> List.foldl applyGameDelta oldGameWithUpdatedUnpassableTiles


applyGameDelta : Delta -> Game -> Game
applyGameDelta delta game =
    case delta of
        MoveUnit unitId newPosition ->
            case Dict.get unitId game.unitById of
                Nothing ->
                    game

                Just unit ->
                    let
                        currentTilePosition =
                            vec2Tile unit.position

                        newTilePosition =
                            vec2Tile newPosition
                    in
                    if currentTilePosition /= newTilePosition && Set.member newTilePosition game.unpassableTiles then
                        -- destination tile occupied, don't move
                        game
                    else
                        -- destination tile available, mark it as occupied and move unit
                        { game
                            | unitById = game.unitById |> Dict.insert unitId { unit | position = newPosition }
                            , unpassableTiles = game.unpassableTiles |> Set.insert newTilePosition
                        }

        UnitEntersBase unitId baseId ->
            game



-- Init


init : ( Model, Cmd Msg )
init =
    let
        terrainObstacles =
            [ ( 0, 0 )
            , ( 1, 0 )
            , ( 2, 0 )
            , ( 3, 0 )
            , ( 3, 1 )
            ]
                |> Set.fromList
    in
    noCmd
        { baseById =
            Dict.empty
                |> addBase 99 (vec2 3 2)
        , unitById =
            Dict.empty
                |> addUnit 0 (vec2 -2 -5)
                |> addUnit 1 (vec2 2 -4.1)
                |> addUnit 2 (vec2 2 -4.2)
                |> addUnit 3 (vec2 2 -4.3)
                |> addUnit 4 (vec2 2 -4.11)
                |> addUnit 5 (vec2 2 -4.3)
                |> addUnit 6 (vec2 2 -4.02)
        , target = vec2 2 4

        -- TODO: Add bases
        , staticObstacles = terrainObstacles

        --
        , unpassableTiles = Set.empty
        }



-- Main


type Msg
    = OnAnimationFrame Time
    | OnClick


type alias Model =
    Game



-- Update


noCmd : Model -> ( Model, Cmd a )
noCmd model =
    ( model, Cmd.none )


update : Vec2 -> Msg -> Model -> ( Model, Cmd Msg )
update mousePosition msg model =
    case msg of
        OnClick ->
            noCmd { model | target = Vec2.scale 10 mousePosition }

        OnAnimationFrame dt ->
            noCmd (updateGame dt model)



-- View


checkersBackground : Float -> Svg a
checkersBackground size =
    let
        squareSize =
            1.0

        s =
            toString squareSize

        s2 =
            toString (squareSize * 2)
    in
    Svg.g
        []
        [ Svg.defs
            []
            [ Svg.pattern
                [ id "grid"
                , width s2
                , height s2
                , patternUnits "userSpaceOnUse"
                ]
                [ Svg.rect
                    [ x "0"
                    , y "0"
                    , width s
                    , height s
                    , fill "#eee"
                    ]
                    []
                , Svg.rect
                    [ x s
                    , y s
                    , width s
                    , height s
                    , fill "#eee"
                    ]
                    []
                ]
            ]
        , Svg.rect
            [ fill "url(#grid)"
            , x <| toString <| -size / 2
            , y <| toString <| -size / 2
            , width <| toString size
            , height <| toString size
            ]
            []
        ]


circle : Vec2 -> String -> Float -> Svg a
circle pos color size =
    Svg.circle
        [ Vec2.getX pos |> toString |> cx
        , Vec2.getY pos |> toString |> cy
        , size |> toString |> r
        , fill color
        ]
        []


square : Vec2 -> String -> Float -> Svg a
square pos color size =
    Svg.rect
        [ Vec2.getX pos |> toString |> x
        , Vec2.getY pos |> toString |> y
        , size |> toString |> width
        , size |> toString |> height
        , fill color
        ]
        []


view : Model -> Svg Msg
view game =
    Svg.g
        [ transform "scale(0.1, 0.1)" ]
        [ checkersBackground 10
        , game.unitById
            |> Dict.values
            |> List.map (\unit -> circle unit.position "blue" 0.5)
            |> Svg.g []
        , game.staticObstacles
            |> Set.toList
            |> List.map (\pos -> square (tile2Vec pos) "gray" 1)
            |> Svg.g []
        , circle game.target "red" 0.5
        ]



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ AnimationFrame.diffs OnAnimationFrame
        , Mouse.clicks (always OnClick)
        ]
