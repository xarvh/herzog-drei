module SplitScreen
    exposing
        ( Viewport
        , makeViewports
        , mouseScreenToViewport
        , viewportToSvgAttributes
        , viewportsWrapper
        )

import Html exposing (Html)
import Html.Attributes
import Svg exposing (Attribute)
import Svg.Attributes
import Window


-- Types


type alias Rect a =
    { x : a
    , y : a
    , w : a
    , h : a
    }


type alias Cell =
    Rect Float


type alias Viewport =
    Rect Int



-- Mouse coordinate conversion


mouseScreenToViewport : { x : Int, y : Int } -> Viewport -> ( Float, Float )
mouseScreenToViewport mouse viewport =
    let
        minSize =
            min viewport.w viewport.h

        pixelX =
            mouse.x - viewport.x - viewport.w // 2

        pixelY =
            1 - mouse.y + viewport.y + viewport.h // 2
    in
    ( toFloat pixelX / toFloat minSize, toFloat pixelY / toFloat minSize )



-- Svg Attributes


viewportToViewBox : Viewport -> Svg.Attribute a
viewportToViewBox viewport =
    let
        pixelW =
            toFloat viewport.w

        pixelH =
            toFloat viewport.h

        minSize =
            min pixelW pixelH

        w =
            pixelW / minSize

        h =
            pixelH / minSize
    in
    [ -w / 2, -h / 2, w, h ]
        |> List.map toString
        |> String.join " "
        |> Svg.Attributes.viewBox


viewportToStyle : Viewport -> List ( String, String )
viewportToStyle viewport =
    [ ( "width", toString viewport.w ++ "px" )
    , ( "height", toString viewport.h ++ "px" )
    , ( "left", toString viewport.x ++ "px" )
    , ( "top", toString viewport.y ++ "px" )
    ]


viewportToSvgAttributes : Viewport -> List (Svg.Attribute a)
viewportToSvgAttributes viewport =
    [ Html.Attributes.style (viewportToStyle viewport)
    , viewportToViewBox viewport
    ]



-- Viewports


cellToViewport : Window.Size -> Cell -> Viewport
cellToViewport window { x, y, w, h } =
    { x = floor <| x * toFloat window.width
    , y = floor <| y * toFloat window.height
    , w = floor <| w * toFloat window.width
    , h = floor <| h * toFloat window.height
    }


makeRowCells : Float -> Int -> Int -> List Cell
makeRowCells rowHeight rowIndex numberOfColumns =
    let
        columnWidth =
            1.0 / toFloat numberOfColumns

        y =
            toFloat rowIndex * rowHeight

        columnIndexToCell index =
            { x = toFloat index * columnWidth
            , y = y
            , w = columnWidth
            , h = rowHeight
            }
    in
    List.range 0 (numberOfColumns - 1) |> List.map columnIndexToCell


makeViewports : Window.Size -> Int -> List Viewport
makeViewports windowSize numberOfPlayers =
    {- TODO
       * Drop the assumption that screens are landscape

       * An interesting mathematical problem: how to partition a rectangle whose dimensions ratio
        is `screenRatio` into rows of rectangles that have, as much as possible
         - width to height ratio ~= 1
         - same surface of all other rectangles
    -}
    let
        rows =
            case numberOfPlayers of
                0 ->
                    [ 1 ]

                1 ->
                    [ 1 ]

                2 ->
                    [ 2 ]

                3 ->
                    [ 3 ]

                4 ->
                    [ 2, 2 ]

                5 ->
                    [ 3, 2 ]

                6 ->
                    [ 3, 3 ]

                7 ->
                    [ 4, 3 ]

                _ ->
                    [ 4, 4 ]

        numberOfRows =
            List.length rows

        rowHeight =
            1.0 / toFloat numberOfRows
    in
    rows
        |> List.indexedMap (makeRowCells rowHeight)
        |> List.concat
        |> List.map (cellToViewport windowSize)


viewportsWrapper : List (Html a) -> Html a
viewportsWrapper =
    Html.div
        [ Html.Attributes.style
            [ ( "width", "100vw" )
            , ( "height", "100vh" )
            , ( "overflow", "hidden" )
            ]
        ]
