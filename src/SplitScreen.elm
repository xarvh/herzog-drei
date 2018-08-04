module SplitScreen exposing (..)

-- TODO: Split Svg and WebGL code

import Html exposing (Html)
import Html.Attributes
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Svg exposing (Attribute)
import Svg.Attributes


-- Types


type alias Size =
    { width : Int
    , height : Int
    }


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


defaultViewport =
    { x = 0
    , y = 0
    , w = 640
    , h = 480
    }



--


style : List ( String, String ) -> List (Html.Attribute a)
style tuples =
    List.map (\( k, v ) -> Html.Attributes.style k v) tuples



-- Size


viewportSizeInGameUnits : Viewport -> Float -> ( Float, Float )
viewportSizeInGameUnits viewport minSizeInGameUnits =
    let
        minSize =
            toFloat (min viewport.w viewport.h)

        w =
            minSizeInGameUnits * toFloat viewport.w / minSize

        h =
            minSizeInGameUnits * toFloat viewport.h / minSize
    in
    ( w, h )


isWithinViewport : Viewport -> Vec2 -> Float -> (Vec2 -> Float -> Bool)
isWithinViewport viewport centeredOn minSizeInGameUnits =
    let
        -- center coordinates
        c =
            Vec2.toRecord centeredOn

        -- half size
        ( hw, hh ) =
            viewportSizeInGameUnits viewport (minSizeInGameUnits / 2)

        minX =
            c.x - hw

        maxX =
            c.x + hw

        minY =
            c.x - hh

        maxY =
            c.x + hh

        test position r =
            let
                p =
                    Vec2.toRecord position
            in
            (p.x < maxX + r) && (p.x > minX - r) && (p.y < maxY + r) && (p.y > minY - r)
    in
    test



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



-- Fit


fitWidthAndHeight : Float -> Float -> Viewport -> Float
fitWidthAndHeight width height viewport =
    let
        minSize =
            min viewport.w viewport.h

        -- fit width
        xScale =
            width / (toFloat viewport.w / toFloat minSize)

        -- fit height
        yScale =
            height / (toFloat viewport.h / toFloat minSize)
    in
    max xScale yScale



-- Svg Attributes


{-| Ensures that the screen will fit a 1x1 square area
-}
normalizedSize : Viewport -> { width : Float, height : Float }
normalizedSize viewport =
    let
        pixelW =
            toFloat viewport.w

        pixelH =
            toFloat viewport.h

        minSize =
            min pixelW pixelH
    in
    { width = pixelW / minSize
    , height = pixelH / minSize
    }


viewportToViewBox : Viewport -> Svg.Attribute a
viewportToViewBox viewport =
    let
        { width, height } =
            normalizedSize viewport
    in
    [ -width / 2, -height / 2, width, height ]
        |> List.map String.fromFloat
        |> String.join " "
        |> Svg.Attributes.viewBox


viewportToStyle : Viewport -> List ( String, String )
viewportToStyle viewport =
    [ ( "width", String.fromInt viewport.w ++ "px" )
    , ( "height", String.fromInt viewport.h ++ "px" )
    , ( "left", String.fromInt viewport.x ++ "px" )
    , ( "top", String.fromInt viewport.y ++ "px" )
    ]


viewportToSvgAttributes : Viewport -> List (Svg.Attribute a)
viewportToSvgAttributes viewport =
    viewportToViewBox viewport
        :: style (viewportToStyle viewport)


viewportToWebGLAttributes : Viewport -> List (Svg.Attribute a)
viewportToWebGLAttributes viewport =
    List.concat
        [ [ Svg.Attributes.width (String.fromInt viewport.w)
          , Svg.Attributes.height (String.fromInt viewport.h)
          ]
        , style (viewportToStyle viewport)
        ]



-- Viewports


cellToViewport : Size -> Cell -> Viewport
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


makeViewports : Size -> Int -> List Viewport
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
    [ ( "width", "100vw" )
    , ( "height", "100vh" )
    , ( "overflow", "hidden" )
    ]
        |> style
        |> Html.div
