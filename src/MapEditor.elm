module MapEditor exposing (..)

import Game exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, style)
import Html.Events
import Mouse
import Random
import Set exposing (Set)
import SplitScreen exposing (Viewport)
import Task
import View.Background
import View.Game
import Window


sidebarWidthInPixels : Int
sidebarWidthInPixels =
    100


viewport : Model -> Viewport
viewport model =
    let
        size =
            { width = model.windowSize.width - sidebarWidthInPixels
            , height = model.windowSize.height
            }
    in
    SplitScreen.makeViewports size 1
        |> List.head
        |> Maybe.withDefault SplitScreen.defaultViewport



-- Msg


type Msg
    = Noop
    | OnWindowResizes Window.Size
    | OnMapClick
    | OnMouseMoves Mouse.Position



-- Model


type alias Model =
    { game : Game
    , windowSize : Window.Size
    , mousePosition : { x : Int, y : Int }
    , lastClick : { x : Int, y : Int }
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
      , windowSize = { width = sidebarWidthInPixels + 1, height = 1 }
      , lastClick = { x = 0, y = 0 }
      , mousePosition = { x = 0, y = 0 }
      }
    , Window.size |> Task.perform OnWindowResizes
    )



-- Update


noCmd : Model -> ( Model, Cmd Msg )
noCmd model =
    ( model, Cmd.none )


updateOnMouseMove : Mouse.Position -> Model -> Model
updateOnMouseMove position model =
    let
        vp =
            viewport model

        scale =
            SplitScreen.fitWidthAndHeight (toFloat game.halfWidth * 2) (toFloat game.halfHeight * 2) vp

        toTile v =
            v * scale |> floor

        ( x, y ) =
            SplitScreen.mouseScreenToViewport position vp
                |> Tuple.mapFirst toTile
                |> Tuple.mapSecond toTile

        wallTiles =
            Set.singleton ( x, y )

        game =
            model.game

        newGame =
            { game | wallTiles = wallTiles }
    in
    { model
        | mousePosition = { x = x, y = y }
        , game = newGame
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            noCmd model

        OnWindowResizes windowSize ->
            noCmd { model | windowSize = windowSize }

        OnMapClick ->
            noCmd { model | lastClick = model.mousePosition }

        OnMouseMoves position ->
            updateOnMouseMove position model |> noCmd



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
            [ style [ ( "width", toString sidebarWidthInPixels ++ "px" ) ]
            , class "map-editor-sidebar"
            ]
            [ text (toString model.mousePosition)
            ]
        ]



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Window.resizes OnWindowResizes
        , Mouse.moves OnMouseMoves
        ]
