module MapEditor exposing (..)

import Dict exposing (Dict)
import Game exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, style)
import Html.Events
import List.Extra
import Mouse
import Random
import Set exposing (Set)
import SplitScreen exposing (Viewport)
import Task
import View.Background
import View.Game
import Window


toolbarHeightInPixels : Int
toolbarHeightInPixels =
    100


type Symmetry
    = SymmetryCentral
    | SymmetryVertical
    | SymmetryHorizontal
    | SymmetryNone


type WallEditMode
    = WallPlace
    | WallRemove



-- Msg


type Msg
    = Noop
    | OnWindowResizes Window.Size
    | OnMapClick
    | OnMouseMoves Mouse.Position
    | OnMouseButton Bool



-- Model


type alias Model =
    { game : Game
    , windowSize : Window.Size
    , mouseTile : Tile2
    , maybeWallEditMode : Maybe WallEditMode
    , symmetry : Symmetry
    }


init : ( Model, Cmd Msg )
init =
    let
        newGame =
            Game.new { halfWidth = 20, halfHeight = 10 } (Random.initialSeed 0)

        game =
            { newGame | phase = PhasePlay }
    in
    ( { game = game
      , windowSize = { width = 1, height = 1 + toolbarHeightInPixels }
      , mouseTile = ( 0, 0 )
      , maybeWallEditMode = Nothing
      , symmetry = SymmetryCentral
      }
    , Window.size |> Task.perform OnWindowResizes
    )



-- Viewport


viewport : Model -> Viewport
viewport model =
    let
        size =
            { width = model.windowSize.width
            , height = model.windowSize.height - toolbarHeightInPixels
            }
    in
    SplitScreen.makeViewports size 1
        |> List.head
        |> Maybe.withDefault SplitScreen.defaultViewport



-- Map to/from String


ifPositive : Int -> String
ifPositive n =
    if n < 0 then
        ""
    else
        "+"


tileToString : Tile2 -> String
tileToString ( x, y ) =
    ifPositive x ++ toString x ++ ifPositive y ++ toString y


tileListToString : List Tile2 -> String
tileListToString tiles =
    tiles |> List.map tileToString |> String.join ""


symmetryToString : Symmetry -> String
symmetryToString s =
    case s of
        SymmetryCentral ->
            "C"

        SymmetryVertical ->
            "V"

        SymmetryHorizontal ->
            "H"

        SymmetryNone ->
            "0"


mapToString : Model -> String
mapToString { game, symmetry } =
    let
        mainBaseTile =
            game.baseById
                |> Dict.values
                |> List.Extra.find (\b -> b.type_ == BaseMain)
                |> Maybe.map .tile
                |> Maybe.withDefault ( 10, 0 )

        smallBasesTiles =
            game.baseById
                |> Dict.values
                |> List.filter (\b -> b.type_ == BaseSmall)
                |> List.map .tile
    in
    [ symmetryToString symmetry
    , tileToString ( game.halfWidth, game.halfHeight )
    , tileToString mainBaseTile
    , "b"
    , tileListToString smallBasesTiles
    , "w"
    , tileListToString (Set.toList game.wallTiles)
    ]
        |> String.join ""



-- Update


noCmd : Model -> ( Model, Cmd Msg )
noCmd model =
    ( model, Cmd.none )


updateWallAtMouseTile : Model -> Model
updateWallAtMouseTile model =
    case model.maybeWallEditMode of
        Nothing ->
            model

        Just mode ->
            let
                game =
                    model.game

                operation =
                    case mode of
                        WallRemove ->
                            Set.remove

                        WallPlace ->
                            Set.insert

                one =
                    model.mouseTile

                ( x, y ) =
                    one

                two =
                    case model.symmetry of
                        SymmetryCentral ->
                            ( -x, -y )

                        SymmetryVertical ->
                            ( x, -y )

                        SymmetryHorizontal ->
                            ( -x, y )

                        SymmetryNone ->
                            one
            in
            { model
                | game =
                    { game
                        | wallTiles = List.foldl operation game.wallTiles [ one, two ]
                    }
            }


updateOnMouseMove : Mouse.Position -> Model -> Model
updateOnMouseMove mousePositionInPixels model =
    let
        vp =
            viewport model

        scale =
            SplitScreen.fitWidthAndHeight (toFloat model.game.halfWidth * 2) (toFloat model.game.halfHeight * 2) vp

        toTile v =
            v * scale |> floor

        mousePositionInTiles =
            SplitScreen.mouseScreenToViewport mousePositionInPixels vp
                |> Tuple.mapFirst toTile
                |> Tuple.mapSecond toTile
    in
    updateWallAtMouseTile { model | mouseTile = mousePositionInTiles }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            noCmd model

        OnWindowResizes windowSize ->
            noCmd { model | windowSize = windowSize }

        OnMapClick ->
            noCmd model

        OnMouseMoves mousePosition ->
            updateOnMouseMove mousePosition model |> noCmd

        OnMouseButton isPressed ->
            if not isPressed then
                noCmd { model | maybeWallEditMode = Nothing }
            else
                { model
                    | maybeWallEditMode =
                        if Set.member model.mouseTile model.game.wallTiles then
                            Just WallRemove
                        else
                            Just WallPlace
                }
                    |> updateWallAtMouseTile
                    |> noCmd



-- View


terrain : Model -> List View.Background.Rect
terrain { game } =
    let
        hW =
            toFloat game.halfWidth

        hH =
            toFloat game.halfHeight
    in
    [ { x = -hW
      , y = -hH
      , w = 2 * hW
      , h = 2 * hH
      , color = "red"
      , class = ""
      }
    , { x = 2 - hW
      , y = 2 - hH
      , w = 2 * hW - 4
      , h = 2 * hH - 4
      , color = "green"
      , class = ""
      }
    ]


view : Model -> Html Msg
view model =
    div
        [ class "flex relative" ]
        [ div
            [ Html.Events.onClick OnMapClick ]
            [ SplitScreen.viewportsWrapper
                [ View.Game.view (terrain model) (viewport model) model.game ]
            ]
        , div
            [ style [ ( "height", toString toolbarHeightInPixels ++ "px" ) ]
            , class "map-editor-sidebar"
            ]
            [ div [] [ text (toString model.mouseTile) ]
            , div [] [ text (toString model.maybeWallEditMode) ]
            ]
        ]



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Window.resizes OnWindowResizes
        , Mouse.moves OnMouseMoves
        , Mouse.downs (\_ -> OnMouseButton True)
        , Mouse.ups (\_ -> OnMouseButton False)
        ]
