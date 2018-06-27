module Random.List exposing (choose, shuffle)

{-| Extra randomized functions on lists.


# Work with a List

@docs choose, shuffle

-}

import Random exposing (Generator, andThen, constant)


{-| Get nth element of the list. If the list is empty, the selected element
will be `Nothing`.
-}
get : Int -> List a -> Maybe a
get index list =
    list
        |> List.drop index
        |> List.head


{-| Sample without replacement: produce a randomly selected element of the
list, and the list with that element omitted. If the list is empty, the
selected element will be `Nothing`.
-}
choose : List a -> Generator ( Maybe a, List a )
choose list =
    if List.isEmpty list then
        constant ( Nothing, list )
    else
        let
            lastIndex =
                List.length list - 1

            front i =
                List.take i list

            back i =
                List.drop (i + 1) list

            gen =
                Random.int 0 lastIndex
        in
        Random.map
            (\index ->
                ( get index list, List.append (front index) (back index) )
            )
            gen


{-| Shuffle the list using the Fisher-Yates algorithm. Takes O(_n_ log _n_)
time and O(_n_) additional space.
-}
shuffle : List a -> Generator (List a)
shuffle list =
    if List.isEmpty list then
        constant list
    else
        let
            helper : ( List a, List a ) -> Generator ( List a, List a )
            helper ( done, remaining ) =
                choose remaining
                    |> andThen
                        (\( m_val, shorter ) ->
                            case m_val of
                                Nothing ->
                                    constant ( done, shorter )

                                Just val ->
                                    helper ( val :: done, shorter )
                        )
        in
        Random.map Tuple.first (helper ( [], list ))
