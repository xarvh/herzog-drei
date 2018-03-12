module Main exposing (..)

import App
import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Keyboard.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Mouse
import Svg exposing (g, svg)
import Svg.Attributes exposing (transform)
import Task
import Window


type alias Flags =
    { gamepadDatabaseAsString : String
    , gamepadDatabaseKey : String
    , dateNow : Int
    }


type alias Model =
    { app : App.Model
    , mousePosition : Mouse.Position
    , pressedKeys : List Keyboard.Extra.Key
    , windowSize : Window.Size
    }


type Msg
    = OnAppMsg App.Msg
    | OnKeyboardMsg Keyboard.Extra.Msg
    | OnMouseMoves Mouse.Position
    | OnWindowResizes Window.Size


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        ( appModel, appCmd ) =
            App.init
    in
    ( { windowSize =
            { width = 1
            , height = 1
            }
      , pressedKeys = []
      , mousePosition = Mouse.Position 0 0
      , app = appModel
      }
    , Cmd.batch
        [ Window.size |> Task.perform OnWindowResizes
        , appCmd |> Cmd.map OnAppMsg
        ]
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OnAppMsg nestedMsg ->
            let
                ( appModel, appCmd ) =
                    App.update (transformMousePosition model) model.pressedKeys nestedMsg model.app
            in
            ( { model | app = appModel }, Cmd.map OnAppMsg appCmd )

        OnKeyboardMsg keyboardMsg ->
            ( { model | pressedKeys = Keyboard.Extra.update keyboardMsg model.pressedKeys }, Cmd.none )

        OnMouseMoves mousePosition ->
            ( { model | mousePosition = mousePosition }, Cmd.none )

        OnWindowResizes windowSize ->
            ( { model | windowSize = windowSize }, Cmd.none )



-- Transformations


transformMousePosition : Model -> Vec2
transformMousePosition model =
    let
        pixelW =
            toFloat model.windowSize.width

        pixelH =
            toFloat model.windowSize.height

        minSize =
            min pixelW pixelH

        pixelX =
            toFloat model.mousePosition.x - pixelW / 2

        pixelY =
            pixelH / 2 + 1 - toFloat model.mousePosition.y
    in
    vec2 (pixelX / minSize) (pixelY / minSize)


viewBox : Window.Size -> Svg.Attribute a
viewBox windowSize =
    let
        pixelW =
            toFloat windowSize.width

        pixelH =
            toFloat windowSize.height

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


view : Model -> Html Msg
view model =
    div
        [ style
            [ ( "width", "100vw" )
            , ( "height", "100vh" )
            , ( "overflow", "hidden" )
            , ( "position", "absolute" )
            ]
        ]
        [ svg
            [ viewBox model.windowSize
            ]
            [ g
                [ transform "scale(1, -1)" ]
                [ App.view model.app |> Svg.map OnAppMsg ]
            ]
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ App.subscriptions model.app |> Sub.map OnAppMsg
        , Mouse.moves OnMouseMoves
        , Sub.map OnKeyboardMsg Keyboard.Extra.subscriptions
        , Window.resizes OnWindowResizes
        ]


main =
    Html.programWithFlags
        { view = view
        , subscriptions = subscriptions
        , update = update
        , init = init
        }
