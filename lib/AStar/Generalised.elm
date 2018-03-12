module AStar.Generalised exposing (findPath)

{-| This is the real algorithm. The types are generalised here.

We publish simple types to the user which assume they're working with
a 2D grid.

But in reality, we aren't tied to (x,y) positions and we don't care
what the terrain model is. Positions can be any type you like (as long
as it's `comparable` so that we can use it as a dictionary
key).

But...that makes the type signatures pretty unintuitive to newer
users, so we hide them away here.

@docs findPath

-}

import Dict exposing (Dict)
import List.Extra
import Set exposing (Set)
import Tuple exposing (first, second)


{-| Find a path between the `start` and `end` `Position`s. You must
supply a heuristic function and a move function.

See `AStar.findPath` for a getting-started guide. This is a more
general version of that same function.

-}
findPath :
    (comparable -> comparable -> Float)
    -> (comparable -> Set comparable)
    -> comparable
    -> comparable
    -> Float
    -> List comparable
findPath heuristicFn moveFn start end targetDistance =
    astar heuristicFn moveFn end (initialModel start) targetDistance
        |> List.reverse


type alias Model comparable =
    { evaluated : Set comparable
    , openSet : Set comparable
    , costs : Dict comparable Float
    , cameFrom : Dict comparable comparable
    }


initialModel : comparable -> Model comparable
initialModel start =
    { evaluated = Set.empty
    , openSet = Set.singleton start
    , costs = Dict.singleton start 0
    , cameFrom = Dict.empty
    }


cheapestOpen : (comparable -> Float) -> Model comparable -> Maybe ( comparable, Float )
cheapestOpen heuristicFn model =
    model.openSet
        -- TODO rewrite this with a Set.foldl
        |> Set.toList
        |> List.filterMap
            (\position ->
                case Dict.get position model.costs of
                    Nothing ->
                        Nothing

                    Just cost ->
                        let
                            estimatedDistance =
                                heuristicFn position
                        in
                        Just ( ( position, estimatedDistance ), cost + estimatedDistance )
            )
        |> List.Extra.minimumBy second
        |> Maybe.map Tuple.first


reconstructPath : Dict comparable comparable -> comparable -> List comparable
reconstructPath cameFrom goal =
    case Dict.get goal cameFrom of
        Nothing ->
            []

        Just next ->
            goal :: reconstructPath cameFrom next


updateCost : comparable -> comparable -> Model comparable -> Model comparable
updateCost cheapestPosition neighbour model =
    let
        newCameFrom =
            Dict.insert neighbour cheapestPosition model.cameFrom

        cost =
            reconstructPath newCameFrom neighbour
                |> List.length
                |> toFloat

        newCosts =
            Dict.insert neighbour cost model.costs

        newModel =
            { model
                | costs = newCosts
                , cameFrom = newCameFrom
            }
    in
    case Dict.get neighbour model.costs of
        Nothing ->
            newModel

        Just previousCost ->
            if cost < previousCost then
                newModel
            else
                model


astar :
    (comparable -> comparable -> Float)
    -> (comparable -> Set comparable)
    -> comparable
    -> Model comparable
    -> Float
    -> List comparable
astar heuristicFn moveFn goal model targetDistance =
    case cheapestOpen (heuristicFn goal) model of
        Nothing ->
            [] --reconstructPath model.cameFrom goal

        Just ( cheapestPosition, estimatedDistance ) ->
            if estimatedDistance <= targetDistance then
                reconstructPath model.cameFrom goal
            else
                let
                    modelPopped =
                        { model
                            | openSet = Set.remove cheapestPosition model.openSet
                            , evaluated = Set.insert cheapestPosition model.evaluated
                        }

                    neighbours =
                        moveFn cheapestPosition

                    newNeighbours =
                        Set.diff neighbours modelPopped.evaluated

                    modelWithNeighbours =
                        { modelPopped
                            | openSet =
                                Set.union modelPopped.openSet
                                    newNeighbours
                        }

                    modelWithCosts =
                        Set.foldl (updateCost cheapestPosition) modelWithNeighbours newNeighbours
                in
                astar heuristicFn moveFn goal modelWithCosts targetDistance
