module App exposing (..)

import AStar exposing (Position)
import AnimationFrame
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Mouse
import Set exposing (Set)
import Svg exposing (Svg)
import Svg.Attributes exposing (..)
import Time exposing (Time)


--


obstacles =
    [ ( 0, 0 )
    , ( 1, 0 )
    , ( 2, 0 )
    , ( 3, 0 )
    , ( 3, 1 )
    ]
        |> Set.fromList


getAvailableMoves : Set Position -> Position -> Set Position
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



--


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


vec2Tile : Vec2 -> ( Int, Int )
vec2Tile v =
    let
        ( x, y ) =
            Vec2.toTuple v
    in
    ( floor x, floor y )


tile2Vec : ( Int, Int ) -> Vec2
tile2Vec ( x, y ) =
    vec2 (toFloat x) (toFloat y)


unitThink : Float -> Vec2 -> List Unit -> Unit -> Unit
unitThink dt target otherUnits unit =
    let
        targetDistance =
            0

        unitTile =
            vec2Tile unit.position

        targetTile =
            vec2Tile target
    in
    if AStar.straightLineCost unitTile targetTile <= targetDistance then
        unit
    else
        let
            occupiedPositions =
                otherUnits
                    |> List.map (.position >> vec2Tile)
                    |> Set.fromList
                    |> Set.remove (vec2Tile unit.position)
                    |> Set.union obstacles

            path =
                AStar.findPath AStar.straightLineCost (getAvailableMoves occupiedPositions) unitTile targetTile targetDistance

            idealDelta =
                case path of
                    [] ->
                        Vec2.sub target unit.position

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
        if Set.member (vec2Tile newPosition) occupiedPositions then
            unit
        else
            { unit | position = newPosition }



-- Msg


type Msg
    = OnAnimationFrame Time
    | OnClick



-- Model


type alias Unit =
    { id : Int
    , position : Vec2
    }


type alias Model =
    { units : List Unit
    , target : Vec2
    }



-- Init


init : ( Model, Cmd Msg )
init =
    noCmd
        { units =
            [ Unit 0 (vec2 -2 -5)
            , Unit 1 (vec2 2 -4.1)
            , Unit 2 (vec2 2 -4.2)
            , Unit 3 (vec2 2 -4.3)
            , Unit 4 (vec2 2 -4.11)
            , Unit 5 (vec2 2 -4.3)
            , Unit 6 (vec2 2 -4.02)
            ]
        , target = vec2 2 4
        }



-- Update


noCmd : Model -> ( Model, Cmd a )
noCmd model =
    ( model, Cmd.none )


unitsThink : Float -> Vec2 -> List Unit -> List Unit -> List Unit
unitsThink dt target unitsDone unitsTodo =
    case unitsTodo of
        [] ->
            unitsDone

        head :: tail ->
            let
                updatedUnit =
                    unitThink dt target (unitsDone ++ tail) head
            in
            unitsThink dt target (updatedUnit :: unitsDone) tail


update : Vec2 -> Msg -> Model -> ( Model, Cmd Msg )
update mousePosition msg model =
    case msg of
        OnClick ->
            noCmd { model | target = Vec2.scale 10 mousePosition }

        OnAnimationFrame dt ->
            noCmd { model | units = unitsThink dt model.target [] model.units }



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
view model =
    Svg.g
        [ transform "scale(0.1, 0.1)" ]
        [ checkersBackground 10
        , model.units
            |> List.map (\unit -> circle unit.position "blue" 0.5)
            |> Svg.g []
        , obstacles
            |> Set.toList
            |> List.map (\( x, y ) -> square (vec2 x y) "black" 1)
            |> Svg.g []
        , circle model.target "red" 0.5
        ]



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ AnimationFrame.diffs OnAnimationFrame
        , Mouse.clicks (always OnClick)
        ]
