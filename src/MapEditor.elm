module MapEditor exposing (..)

import Base
import Dict exposing (Dict)
import Game exposing (..)
import Html exposing (..)
import Html.Attributes as SA exposing (..)
import Html.Events exposing (onBlur, onClick, onFocus, onInput)
import Keyboard
import List.Extra
import Map exposing (Map)
import Mouse
import Random
import Set exposing (Set)
import Shell exposing (Shell)
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


type TextInputField
    = FieldMapJson



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
    | OnChangeSize Dimension String
    | OnKeyPress Keyboard.KeyCode
    | OnTextInput TextInputField String
    | OnTextBlur


type Dimension
    = DimensionWidth
    | DimensionHeight


setDimension : Dimension -> Int -> Map -> Map
setDimension dimension magnitude map =
    case dimension of
        DimensionWidth ->
            { map | halfWidth = magnitude }

        DimensionHeight ->
            { map | halfHeight = magnitude }



-- Model


type alias Model =
    { map : Map
    , windowSize : Window.Size
    , mouseTile : Tile2
    , editMode : EditMode
    , symmetry : Symmetry
    , error : String
    , maybeFocus : Maybe ( String, TextInputField )
    }


init : Model
init =
    let
        map =
            { name = ""
            , author = ""
            , halfWidth = 20
            , halfHeight = 10
            , bases = Dict.empty
            , wallTiles = Set.empty
            }
    in
    { map = map
    , windowSize = { width = 1, height = 1 + toolbarHeightInPixels }
    , mouseTile = ( 0, 0 )
    , editMode = EditWalls Nothing
    , symmetry = SymmetryCentral
    , error = ""
    , maybeFocus = Nothing
    }



-- Coordinate shenanigans


viewport : Shell -> Viewport
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


isWithinMap : Map -> Tile2 -> Bool
isWithinMap map ( x, y ) =
    True
        && (x >= -map.halfWidth)
        && (x < map.halfWidth)
        && (y >= -map.halfHeight)
        && (y < map.halfHeight)


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


addBase : Symmetry -> BaseType -> Tile2 -> Map -> Map
addBase symmetry baseType targetTile map =
    let
        shiftedTile =
            shiftTile symmetry targetTile

        tiles =
            Base.tiles baseType shiftedTile
    in
    if List.all (isWithinMap map) tiles then
        tiles
            |> List.map (findBasesAt map)
            |> List.concat
            |> List.foldl removeBase map
            |> (\map -> { map | bases = Dict.insert shiftedTile baseType map.bases })
    else
        map



-- Update


noCmd : Model -> ( Model, Cmd Msg )
noCmd model =
    ( model, Cmd.none )


update : Msg -> Shell -> Model -> ( Model, Cmd Msg )
update msg shell model =
    case msg of
        Noop ->
            noCmd model

        OnWindowResizes windowSize ->
            noCmd { model | windowSize = windowSize }

        OnMapClick ->
            noCmd model

        OnMouseMoves mousePosition ->
            updateOnMouseMove mousePosition shell model |> noCmd

        OnMouseClick ->
            case model.editMode of
                EditWalls _ ->
                    noCmd model

                EditMainBase ->
                    updateBase BaseMain model |> noCmd

                EditSmallBases ->
                    updateBase BaseSmall model |> noCmd

        OnMouseButton isPressed ->
            if not (isEditWalls model.editMode) then
                noCmd model
            else if not isPressed then
                noCmd { model | editMode = EditWalls Nothing }
            else if isWithinMap model.map model.mouseTile then
                { model
                    | editMode =
                        EditWalls
                            (if Set.member model.mouseTile model.map.wallTiles then
                                Just WallRemove
                             else
                                Just WallPlace
                            )
                }
                    |> updateWallAtMouseTile
                    |> noCmd
            else
                noCmd model

        OnSwitchSymmetry symmetry ->
            updateOnSymmetry symmetry model |> noCmd

        OnChangeSize dimension magnitudeAsString ->
            case String.toInt magnitudeAsString of
                Err _ ->
                    noCmd model

                Ok n ->
                    noCmd { model | map = setDimension dimension (clamp minSize maxSize n) model.map }

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

        OnTextInput inputField string ->
            updateOnTextInput inputField string { model | maybeFocus = Just ( string, inputField ) } |> noCmd

        OnTextBlur ->
            noCmd { model | maybeFocus = Nothing }


updateWallAtMouseTile : Model -> Model
updateWallAtMouseTile model =
    case model.editMode of
        EditWalls (Just mode) ->
            let
                map =
                    model.map

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
                    [ one, two ] |> List.filter (isWithinMap map)
            in
            { model
                | map =
                    { map
                        | wallTiles = List.foldl operation map.wallTiles tiles
                    }
            }

        _ ->
            model


updateOnSymmetry : Symmetry -> Model -> Model
updateOnSymmetry sym model =
    { model | symmetry = sym }


updateOnMouseMove : Mouse.Position -> Shell -> Model -> Model
updateOnMouseMove mousePositionInPixels shell model =
    let
        vp =
            viewport shell

        scale =
            SplitScreen.fitWidthAndHeight (toFloat model.map.halfWidth * 2) (toFloat model.map.halfHeight * 2) vp

        toTile v =
            v * scale |> floor

        mousePositionInTiles =
            SplitScreen.mouseScreenToViewport mousePositionInPixels vp
                |> Tuple.mapFirst toTile
                |> Tuple.mapSecond toTile
    in
    updateWallAtMouseTile { model | mouseTile = mousePositionInTiles }


findBasesAt : Map -> Tile2 -> List Tile2
findBasesAt map tile =
    let
        onTile base baseType =
            List.member tile (Base.tiles baseType base)
    in
    Dict.filter onTile map.bases |> Dict.keys


removeBase : Tile2 -> Map -> Map
removeBase base map =
    { map | bases = Dict.remove base map.bases }


updateBase : BaseType -> Model -> Model
updateBase baseType model =
    { model
        | map =
            case findBasesAt model.map model.mouseTile of
                [] ->
                    model.map
                        |> addBase model.symmetry baseType (mirrorTile model.symmetry model.mouseTile)
                        |> addBase model.symmetry baseType model.mouseTile

                base :: _ ->
                    model.map
                        |> removeBase base
                        |> removeBase (mirrorTile model.symmetry base)
    }


updateOnTextInput : TextInputField -> String -> Model -> Model
updateOnTextInput inputField string model =
    case inputField of
        FieldMapJson ->
            case Map.fromString string of
                Err message ->
                    { model | error = message }

                Ok map ->
                    { model | error = "" }



-- View


terrain : Model -> List View.Background.Rect
terrain { map } =
    let
        hW =
            toFloat map.halfWidth

        hH =
            toFloat map.halfHeight
    in
    [ { x = -hW
      , y = -hH
      , w = 2 * hW
      , h = 2 * hH
      , color = "red"
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


sizeInput : Model -> ( String, Map -> Int, Dimension ) -> Html Msg
sizeInput model ( name, get, dimension ) =
    div
        [ class "flex" ]
        [ input
            [ type_ "number"
            , model.map |> get |> toString |> value
            , SA.min (toString minSize)
            , SA.max (toString maxSize)
            , onInput (OnChangeSize dimension)
            ]
            []
        , label [ class "mr1" ] [ text name ]
        ]


stringInput : Model -> TextInputField -> String -> Html Msg
stringInput model inputField currentValue =
    let
        maybeUserIsTyping =
            case model.maybeFocus of
                Nothing ->
                    Nothing

                Just ( string, currentFocus ) ->
                    if inputField == currentFocus then
                        Just string
                    else
                        Nothing

        content =
            maybeUserIsTyping |> Maybe.withDefault currentValue
    in
    input
        [ onInput (OnTextInput inputField)
        , onBlur OnTextBlur
        , value content
        , style [ ( "width", "100%" ) ]
        ]
        []


view : Shell -> Model -> Html Msg
view shell model =
    div
        [ class "flex relative" ]
        [ div
            [ Html.Events.onClick OnMapClick ]
            [ SplitScreen.viewportsWrapper [ View.Game.viewMap (terrain model) (viewport shell) model.map ]
            ]
        , div
            [ style [ ( "height", toString toolbarHeightInPixels ++ "px" ) ]
            , class "map-editor-toolbar flex alignCenter nonSelectable"
            ]
            [ div
                []
                [ text "Size"
                , [ ( "Width", .halfWidth, DimensionWidth )
                  , ( "Height", .halfHeight, DimensionHeight )
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
            , div
                [ class "flex1" ]
                [ div [] [ text (toString model.mouseTile) ]
                , stringInput model
                    FieldMapJson
                    (Map.toString model.map)
                , div
                    []
                    [ model.error |> String.left 50 |> text ]
                , div
                    []
                    [ case Map.validate model.map of
                        Err error ->
                            span [ class "red" ] [ text error ]

                        Ok vm ->
                            text "Validation Ok!"
                    ]
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
