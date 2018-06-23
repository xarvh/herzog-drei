module Pathfinding exposing (..)

import Base
import Dict exposing (Dict)
import Game exposing (Game, Tile2)
import List.Extra
import Set exposing (Set)


-- Dijkstra


type alias Distance =
    Float


type alias Cost =
    Float


type alias NodeId =
    -- NodeId is used a Dict key, and its type is crucial for speed.
    -- With the core Dict type, using a ( Int, Int ) instead of just
    -- Int will make the algorithm *several times* slower
    Int


type alias OpenNodes =
    List ( NodeId, Distance )


type alias DistancesById =
    Dict NodeId Distance


{-| This one is a bit faster than List.filter
-}
listRemove : NodeId -> OpenNodes -> OpenNodes
listRemove nodeId openNodes =
    let
        rm ( id, distance ) accumulator =
            if id == nodeId then
                accumulator
            else
                ( id, distance ) :: accumulator
    in
    List.foldl rm [] openNodes


dijkstra : (NodeId -> Set ( NodeId, Cost )) -> List NodeId -> Dict NodeId Distance
dijkstra getAdjacent startIds =
    let
        -- Open nodes are nodes that HAVE been evaluated but whose neighbors have NOT been evaluated
        initialOpenNodes : OpenNodes
        initialOpenNodes =
            List.map (\id -> ( id, 0 )) startIds

        initialDistances : DistancesById
        initialDistances =
            Dict.fromList initialOpenNodes

        addNode : Distance -> ( NodeId, Cost ) -> ( OpenNodes, DistancesById ) -> ( OpenNodes, DistancesById )
        addNode bestDistance ( nodeId, cost ) ( openNodes, distancesById ) =
            let
                distance =
                    cost + bestDistance
            in
            case Dict.get nodeId distancesById of
                Nothing ->
                    ( ( nodeId, distance ) :: openNodes, Dict.insert nodeId distance distancesById )

                Just oldDistance ->
                    if distance < oldDistance then
                        ( openNodes, Dict.insert nodeId distance distancesById )
                    else
                        ( openNodes, distancesById )

        iteration : OpenNodes -> DistancesById -> DistancesById
        iteration openNodes distancesById =
            case List.Extra.minimumBy Tuple.second openNodes of
                Nothing ->
                    distancesById

                Just ( bestNode, bestDistance ) ->
                    let
                        ( newOpenNode, newDistances ) =
                            Set.foldl (addNode bestDistance) ( openNodes, distancesById ) (getAdjacent bestNode)
                    in
                    iteration (listRemove bestNode newOpenNode) newDistances
    in
    iteration initialOpenNodes initialDistances



-- Coordinates shuffling


cartesianToNodeId : Game -> Tile2 -> NodeId
cartesianToNodeId { halfWidth, halfHeight } ( x, y ) =
    let
        w =
            halfWidth * 2
    in
    (x + halfWidth) + (y + halfHeight) * w


nodeIdToCartesian : Game -> NodeId -> Tile2
nodeIdToCartesian { halfWidth, halfHeight } id =
    let
        w =
            halfWidth * 2
    in
    ( (id % w) - halfWidth, (id // w) - halfHeight )



-- Rectangular map geometry


availableMoves : Game -> Tile2 -> Set ( Tile2, Cost )
availableMoves { halfWidth, halfHeight, staticObstacles } ( x, y ) =
    let
        add : Int -> Int -> Cost -> Set ( Tile2, Cost ) -> Set ( Tile2, Cost )
        add xx yy cost set =
            if
                True
                    && (xx >= -halfWidth)
                    && (xx < halfWidth)
                    && (yy >= -halfHeight)
                    && (yy < halfHeight)
                    && not (Set.member ( xx, yy ) staticObstacles)
            then
                Set.insert ( ( xx, yy ), cost ) set
            else
                set
    in
    Set.empty
        |> add (x - 1) y 1
        |> add (x + 1) y 1
        |> add x (y - 1) 1
        |> add x (y + 1) 1
        --
        |> add (x + 1) (y + 1) 1.5
        |> add (x - 1) (y + 1) 1.5
        |> add (x - 1) (y - 1) 1.5
        |> add (x + 1) (y - 1) 1.5



--


maybeFind : (a -> b) -> (b -> Bool) -> List a -> Maybe b
maybeFind transform condition list =
    case list of
        [] ->
            Nothing

        a :: xs ->
            let
                b =
                    transform a
            in
            if condition b then
                Just b
            else
                maybeFind transform condition xs


maybeBaseAt : Game -> Tile2 -> Maybe (List Tile2)
maybeBaseAt game target =
    -- TODO: once we have precalculated base proximity, use that
    game.baseById
        |> Dict.values
        |> maybeFind (\b -> Base.tiles b.type_ b.tile) (List.member target)


makePaths : Game -> Tile2 -> Dict Tile2 Distance
makePaths game target =
    let
        xyToId : Tile2 -> NodeId
        xyToId =
            cartesianToNodeId game

        idToXy =
            nodeIdToCartesian game

        availableMovesNode nodeId =
            nodeId
                |> idToXy
                |> availableMoves game
                |> Set.map (Tuple.mapFirst xyToId)

        keyNodeIdToKeyCartesian nodeId distance d =
            Dict.insert (idToXy nodeId) distance d

        targetTiles =
            case maybeBaseAt game target of
                Nothing ->
                    [ target ]

                Just tiles ->
                    tiles
    in
    targetTiles
        |> List.map xyToId
        |> dijkstra availableMovesNode
        |> Dict.foldl keyNodeIdToKeyCartesian Dict.empty



--


moves : Game -> Tile2 -> Dict Tile2 Distance -> List Tile2
moves game startTile paths =
    let
        currentDistance =
            Dict.get startTile paths |> Maybe.withDefault 999

        mapTile : Tile2 -> Maybe ( Tile2, Distance )
        mapTile tile =
            Dict.get tile paths |> Maybe.map (\distance -> ( tile, distance ))
    in
    availableMoves game startTile
        |> Set.toList
        |> List.map Tuple.first
        |> List.filterMap mapTile
        |> List.filter (\( tile, distance ) -> distance < currentDistance)
        |> List.sortBy Tuple.second
        |> List.map Tuple.first
