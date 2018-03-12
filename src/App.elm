module App exposing (..)

import AStar
import AnimationFrame
import Dict exposing (Dict)
import Keyboard.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Mouse
import Set exposing (Set)
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Svg.Events
import Time exposing (Time)


--


type alias TilePosition =
    AStar.Position


tileDistance : TilePosition -> TilePosition -> Float
tileDistance =
    -- Manhattan distance
    AStar.straightLineCost


vectorDistance : Vec2 -> Vec2 -> Float
vectorDistance v1 v2 =
    -- Manhattan distance
    let
        ( x1, y1 ) =
            Vec2.toTuple v1

        ( x2, y2 ) =
            Vec2.toTuple v2
    in
    abs (x1 - x2) + abs (y1 - y2)



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
    , position : TilePosition
    }


addBase : Id -> TilePosition -> Dict Id Base -> Dict Id Base
addBase id position =
    Dict.insert id (Base id 0 position)


baseTiles : Base -> Set TilePosition
baseTiles base =
    let
        ( x, y ) =
            base.position
    in
    [ ( x + 0, y - 1 )
    , ( x - 1, y - 1 )
    , ( x - 1, y + 0 )
    , ( x + 0, y + 0 )
    ]
        |> Set.fromList



-- Units


type alias Unit =
    { id : Id
    , order : UnitOrder
    , position : Vec2
    }


type UnitOrder
    = OrderStay
    | OrderMoveTo Vec2
    | OrderEnterBase Id


addUnit : Id -> Vec2 -> Dict Id Unit -> Dict Id Unit
addUnit id position =
    Dict.insert
        id
        { id = id
        , order = OrderStay
        , position = position
        }


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


unitMove : Float -> Game -> Vec2 -> Unit -> Maybe Delta
unitMove dt game targetPosition unit =
    let
        targetDistance =
            0
    in
    if vectorDistance unit.position targetPosition <= targetDistance then
        Nothing
    else
        let
            unitTile =
                vec2Tile unit.position

            path =
                AStar.findPath
                    tileDistance
                    (getAvailableMoves game.unpassableTiles)
                    unitTile
                    (vec2Tile targetPosition)
                    targetDistance

            idealDelta =
                case path of
                    [] ->
                        Vec2.sub targetPosition unit.position

                    head :: tail ->
                        Vec2.sub (tile2Vec head) (tile2Vec unitTile)

            speed =
                1

            maxLength =
                speed * dt / 1000

            viableDelta =
                clampToRadius maxLength idealDelta
        in
        Just (MoveUnit unit.id viableDelta)


unitThink : Float -> Game -> Unit -> Maybe Delta
unitThink dt game unit =
    case unit.order of
        OrderStay ->
            Nothing

        OrderEnterBase baseId ->
            case Dict.get baseId game.baseById of
                Nothing ->
                    Nothing

                Just base ->
                    if vectorDistance unit.position (tile2Vec base.position) > 2.1 then
                        unitMove dt game (tile2Vec base.position) unit
                    else
                        Just (UnitEntersBase unit.id base.id)

        OrderMoveTo targetPosition ->
            unitMove dt game targetPosition unit


orderUnit : UnitOrder -> Game -> Game
orderUnit order game =
    case Dict.get game.selectedUnitId game.unitById of
        Nothing ->
            game

        Just unit ->
            let
                unitById =
                    game.unitById |> Dict.insert unit.id { unit | order = order }
            in
            { game | unitById = unitById }



-- Player


playerThink : Float -> Vec2 -> Game -> List Delta
playerThink dt movement game =
    let
        speed =
            2

        dx =
            Vec2.scale (speed * dt / 1000) movement
    in
    [ MovePlayer dx ]



-- Game


type alias Id =
    Int


type Delta
    = MoveUnit Id Vec2
    | UnitEntersBase Id Id
    | MovePlayer Vec2


type alias Game =
    { baseById : Dict Id Base
    , unitById : Dict Id Unit
    , playerPosition : Vec2
    , selectedUnitId : Int

    -- includes terrain and bases
    , staticObstacles : Set TilePosition

    -- this is the union between static obstacles and unit positions
    , unpassableTiles : Set TilePosition
    }


updateGame : Float -> Vec2 -> Game -> Game
updateGame dt movement oldGame =
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
        , playerThink dt movement oldGameWithUpdatedUnpassableTiles
        ]
        |> List.foldl applyGameDelta oldGameWithUpdatedUnpassableTiles


applyGameDelta : Delta -> Game -> Game
applyGameDelta delta game =
    case delta of
        MoveUnit unitId dx ->
            case Dict.get unitId game.unitById of
                Nothing ->
                    game

                Just unit ->
                    let
                        newPosition =
                            Vec2.add unit.position dx

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
            case ( Dict.get unitId game.unitById, Dict.get baseId game.baseById ) of
                ( Just unit, Just base ) ->
                    if base.containedUnits < 4 then
                        let
                            unitById =
                                Dict.remove unit.id game.unitById

                            baseById =
                                Dict.insert base.id { base | containedUnits = base.containedUnits + 1 } game.baseById
                        in
                        { game | unitById = unitById, baseById = baseById }
                    else
                        game

                ( _, _ ) ->
                    game

        MovePlayer dx ->
            let
                newPosition =
                    Vec2.add game.playerPosition dx
            in
            { game | playerPosition = newPosition }



-- Init


init : ( Model, Cmd Msg )
init =
    let
        baseById =
            Dict.empty
                |> addBase 99 ( 0, 0 )

        unitById =
            Dict.empty
                |> addUnit 0 (vec2 -2 -5)
                |> addUnit 1 (vec2 2 -4.1)
                |> addUnit 2 (vec2 2 -4.2)
                |> addUnit 3 (vec2 2 -4.3)
                |> addUnit 4 (vec2 2 -4.11)
                |> addUnit 5 (vec2 2 -4.3)
                |> addUnit 6 (vec2 2 -4.02)

        terrainObstacles =
            [ ( 0, 0 )
            , ( 1, 0 )
            , ( 2, 0 )
            , ( 3, 0 )
            , ( 3, 1 )
            ]
                |> Set.fromList

        staticObstacles =
            baseById
                |> Dict.values
                |> List.map baseTiles
                |> List.foldl Set.union terrainObstacles
    in
    noCmd
        { baseById = baseById
        , unitById = unitById
        , playerPosition = vec2 -3 -3
        , selectedUnitId = 99
        , staticObstacles = staticObstacles
        , unpassableTiles = Set.empty
        }



-- Main


type Msg
    = OnAnimationFrame Time
    | OnTerrainClick
    | OnUnitClick Id
    | OnBaseClick Id


type alias Model =
    Game



-- Update


noCmd : Model -> ( Model, Cmd a )
noCmd model =
    ( model, Cmd.none )


update : Vec2 -> List Keyboard.Extra.Key -> Msg -> Model -> ( Model, Cmd Msg )
update mousePosition pressedKeys msg model =
    case msg of
        OnTerrainClick ->
            model
                |> orderUnit (OrderMoveTo (Vec2.scale 10 mousePosition))
                |> noCmd

        OnUnitClick unitId ->
            noCmd { model | selectedUnitId = unitId }

        OnBaseClick baseId ->
            model
                |> orderUnit (OrderEnterBase baseId)
                |> noCmd

        OnAnimationFrame dt ->
            let
                { x, y } =
                    Keyboard.Extra.wasd pressedKeys

                movement =
                    vec2 (toFloat x) (toFloat y) |> clampToRadius 1
            in
            noCmd (updateGame dt movement model)



-- View


checkersBackground : Float -> Svg Msg
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
        [ Svg.Events.onClick OnTerrainClick ]
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


viewBase : Base -> Svg Msg
viewBase base =
    let
        v =
            Vec2.add (tile2Vec base.position) (vec2 -1 -1)
    in
    Svg.g
        [ Svg.Events.onClick (OnBaseClick base.id) ]
        [ square v "purple" 2
        , square v "#00c" (toFloat base.containedUnits * 0.5)
        ]


viewUnit : Game -> Unit -> Svg Msg
viewUnit game unit =
    let
        isSelected =
            game.selectedUnitId == unit.id

        color =
            if isSelected then
                "#44f"
            else
                "#00c"
    in
    Svg.g
        [ Svg.Events.onClick (OnUnitClick unit.id) ]
        [ circle unit.position color 0.25 ]


viewPlayer : Game -> Svg a
viewPlayer game =
    circle game.playerPosition "green" 0.5


view : Model -> Svg Msg
view game =
    Svg.g
        [ transform "scale(0.1, 0.1)" ]
        [ checkersBackground 10
        , game.staticObstacles
            |> Set.toList
            |> List.map (\pos -> square (tile2Vec pos) "gray" 1)
            |> Svg.g []
        , game.baseById
            |> Dict.values
            |> List.map viewBase
            |> Svg.g []
        , game.unitById
            |> Dict.values
            |> List.map (viewUnit game)
            |> Svg.g []
        , viewPlayer game
        ]



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ AnimationFrame.diffs OnAnimationFrame
        ]
