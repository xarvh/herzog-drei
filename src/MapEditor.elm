module MapEditor exposing (..)

import Game exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, style)
import Html.Events
import Random
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



-- Model


type alias Model =
    { game : Game
    , windowSize : Window.Size
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
      }
    , Window.size |> Task.perform OnWindowResizes
    )



-- Update


noCmd : Model -> ( Model, Cmd Msg )
noCmd model =
    ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            noCmd model

        OnWindowResizes windowSize ->
            noCmd { model | windowSize = windowSize }



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
        [ class "flex" ]
        [ SplitScreen.viewportsWrapper
            [ View.Game.view (terrain model) (viewport model) model.game ]
        , div
            [ style [ ( "width", toString sidebarWidthInPixels ++ "px" ) ] ]
            [ text "LOOOOL"
            ]
        ]



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Window.resizes OnWindowResizes
