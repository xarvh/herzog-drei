module Random.Extra exposing (..)

import Random exposing (Generator, constant, int, map)


{-| Turn a list of generators into a generator of lists.
-}
combine : List (Generator a) -> Generator (List a)
combine generators =
    case generators of
        [] ->
            constant []

        g :: gs ->
            Random.map2 (::) g (combine gs)


{-| Given a list, choose an element uniformly at random. `Nothing` is only
produced if the list is empty.

    type Direction
        = North
        | South
        | East
        | West

    direction : Generator Direction
    direction =
        sample [ North, South, East, West ]
            |> map (Maybe.withDefault North)

-}
sample : List a -> Generator (Maybe a)
sample =
    let
        find k ys =
            case ys of
                [] ->
                    Nothing

                z :: zs ->
                    if k == 0 then
                        Just z
                    else
                        find (k - 1) zs
    in
    \xs -> map (\i -> find i xs) (int 0 (List.length xs - 1))
