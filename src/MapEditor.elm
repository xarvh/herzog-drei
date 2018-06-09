module MapEditor exposing (..)

import Base
import Dict exposing (Dict)
import Game exposing (..)
import Html exposing (..)
import Html.Attributes as SA exposing (..)
import Html.Events exposing (onClick, onInput)
import Keyboard
import List.Extra
import Map
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


minSize =
    Map.minSize


maxSize =
    Map.maxSize



--


type Symmetry
    = SymmetryCentral
    | SymmetryVertical
    | SymmetryHorizontal
    | SymmetryNone


type WallEditMode
    = WallPlace
    | WallRemove


type EditMode
    = EditWalls (Maybe WallEditMode)
    | EditMainBase
    | EditSmallBases


isEditWalls : EditMode -> Bool
isEditWalls editMode =
    case editMode of
        EditWalls _ ->
            True

        _ ->
            False



-- Msg


type Msg
    = Noop
    | OnWindowResizes Window.Size
    | OnMapClick
    | OnMouseMoves Mouse.Position
    | OnMouseButton Bool
    | OnMouseClick
    | OnSwitchSymmetry Symmetry
    | OnSwitchMode EditMode
    | OnChangeSize (Int -> Game -> Game) String
    | OnKeyPress Keyboard.KeyCode



-- Model


type alias Model =
    { game : Game
    , windowSize : Window.Size
    , mouseTile : Tile2
    , editMode : EditMode
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
      , editMode = EditWalls Nothing
      , symmetry = SymmetryCentral
      }
    , Window.size |> Task.perform OnWindowResizes
    )



-- Coordinate shenanigans


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


isWithinMap : Game -> Tile2 -> Bool
isWithinMap game ( x, y ) =
    True
        && (x >= -game.halfWidth)
        && (x < game.halfWidth)
        && (y >= -game.halfHeight)
        && (y < game.halfHeight)


mirrorTile : Symmetry -> Tile2 -> Tile2
mirrorTile symmetry ( x, y ) =
    let
        invert v =
            -v - 1
    in
    case symmetry of
        SymmetryCentral ->
            ( invert x, invert y )

        SymmetryVertical ->
            ( invert x, y )

        SymmetryHorizontal ->
            ( x, invert y )

        SymmetryNone ->
            ( x, y )


shiftForward : Int -> Int
shiftForward v =
    if v >= 0 then
        v + 1
    else
        v


shiftTile : Symmetry -> Tile2 -> Tile2
shiftTile symmetry ( x, y ) =
    ( if symmetry == SymmetryCentral || symmetry == SymmetryVertical then
        shiftForward x
      else
        x
    , if symmetry == SymmetryCentral || symmetry == SymmetryHorizontal then
        shiftForward y
      else
        y
    )



-- Base shenanigans


baseTiles : Base -> List Tile2
baseTiles base =
    Base.tiles base.type_ base.tile


removeBase : Base -> Game -> Game
removeBase base game =
    { game | baseById = Dict.remove base.id game.baseById }


findBaseAt : Game -> Tile2 -> Maybe Base
findBaseAt game tile =
    game.baseById
        |> Dict.values
        |> List.Extra.find (\b -> List.member tile (baseTiles b))


removeBaseAt : Tile2 -> Game -> Game
removeBaseAt tile game =
    case findBaseAt game tile of
        Just base ->
            removeBase base game

        Nothing ->
            game


addBase : Symmetry -> Tile2 -> Game -> Game
addBase symmetry targetTile game =
    let
        shiftedTile =
            shiftTile symmetry targetTile

        tiles =
            Base.tiles BaseSmall shiftedTile
    in
    if List.all (isWithinMap game) tiles then
        List.foldl removeBaseAt game tiles
            |> Base.add BaseSmall shiftedTile
            |> Tuple.first
    else
        game



-- Update


noCmd : Model -> ( Model, Cmd Msg )
noCmd model =
    ( model, Cmd.none )


updateWallAtMouseTile : Model -> Model
updateWallAtMouseTile model =
    case model.editMode of
        EditWalls (Just mode) ->
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
                    mirrorTile model.symmetry one

                tiles =
                    [ one, two ] |> List.filter (isWithinMap game)
            in
            { model
                | game =
                    { game
                        | wallTiles = List.foldl operation game.wallTiles tiles
                    }
            }

        _ ->
            model


updateOnSymmetry : Symmetry -> Model -> Model
updateOnSymmetry sym model =
    { model | symmetry = sym }


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


updateSmallBase : Model -> Model
updateSmallBase model =
    { model
        | game =
            case findBaseAt model.game model.mouseTile of
                Nothing ->
                    model.game
                        |> addBase model.symmetry (mirrorTile model.symmetry model.mouseTile)
                        |> addBase model.symmetry model.mouseTile

                Just base ->
                    model.game
                        |> removeBaseAt base.tile
                        |> removeBaseAt (mirrorTile model.symmetry base.tile)
    }


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

        OnMouseClick ->
            case model.editMode of
                EditWalls _ ->
                    noCmd model

                EditMainBase ->
                    -- TODO
                    noCmd model

                EditSmallBases ->
                    updateSmallBase model |> noCmd

        OnMouseButton isPressed ->
            if not (isEditWalls model.editMode) then
                noCmd model
            else if not isPressed then
                noCmd { model | editMode = EditWalls Nothing }
            else
                { model
                    | editMode =
                        EditWalls
                            (if Set.member model.mouseTile model.game.wallTiles then
                                Just WallRemove
                             else
                                Just WallPlace
                            )
                }
                    |> updateWallAtMouseTile
                    |> noCmd

        OnSwitchSymmetry symmetry ->
            updateOnSymmetry symmetry model |> noCmd

        OnChangeSize setter dimensionAsString ->
            case String.toInt dimensionAsString of
                Err _ ->
                    noCmd model

                Ok n ->
                    noCmd { model | game = setter (clamp minSize maxSize n) model.game }

        OnSwitchMode mode ->
            noCmd { model | editMode = mode }

        OnKeyPress keyCode ->
            case keyCode of
                32 ->
                    noCmd
                        { model
                            | editMode =
                                case model.editMode of
                                    EditWalls _ ->
                                        EditMainBase

                                    EditMainBase ->
                                        EditSmallBases

                                    EditSmallBases ->
                                        EditWalls Nothing
                        }

                _ ->
                    noCmd model



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


symmetryRadio : Model -> ( String, Symmetry ) -> Html Msg
symmetryRadio model ( name, symmetry ) =
    div
        [ class "flex" ]
        [ input
            [ type_ "radio"
            , onClick (OnSwitchSymmetry symmetry)
            , checked (model.symmetry == symmetry)
            ]
            []
        , label [ class "mr1" ] [ text name ]
        ]


modeRadio : Model -> ( String, EditMode ) -> Html Msg
modeRadio model ( name, mode ) =
    div
        [ class "flex" ]
        [ input
            [ type_ "radio"
            , onClick (OnSwitchMode mode)
            , checked (model.editMode == mode)
            ]
            []
        , label [ class "mr1" ] [ text name ]
        ]


sizeInput : Model -> ( String, Game -> Int, Int -> Game -> Game ) -> Html Msg
sizeInput model ( name, get, set ) =
    div
        [ class "flex" ]
        [ input
            [ type_ "number"
            , model.game |> get |> toString |> value
            , SA.min (toString minSize)
            , SA.max (toString maxSize)
            , onInput (OnChangeSize set)
            ]
            []
        , label [ class "mr1" ] [ text name ]
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
            , class "map-editor-toolbar flex alignCenter nonSelectable"
            ]
            [ div
                []
                [ text "Size"
                , [ ( "Width", .halfWidth, \w g -> { g | halfWidth = w } )
                  , ( "Height", .halfHeight, \h g -> { g | halfHeight = h } )
                  ]
                    |> List.map (sizeInput model)
                    |> div []
                ]
            , div
                []
                [ text "Symmetry:"
                , [ ( "Central", SymmetryCentral )
                  , ( "Vertical", SymmetryVertical )
                  , ( "Horizontal", SymmetryHorizontal )
                  , ( "None", SymmetryNone )
                  ]
                    |> List.map (symmetryRadio model)
                    |> div []
                ]
            , div
                []
                [ text "Edit mode"
                , [ ( "Walls", EditWalls Nothing )
                  , ( "Main Base", EditMainBase )
                  , ( "Small Bases", EditSmallBases )
                  ]
                    |> List.map (modeRadio model)
                    |> div []
                ]
            , div [] [ text (toString model.mouseTile) ]
            , div []
                [ input
                    [ model.game
                        |> Map.fromGame "" ""
                        |> Map.toString
                        |> value
                    ]
                    []
                ]
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
        , Mouse.clicks (\_ -> OnMouseClick)
        , Keyboard.ups OnKeyPress
        ]
