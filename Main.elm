module Main exposing (..)

import App
import Html exposing (Html, div)
import Html.Attributes exposing (style)
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
    { windowSize : Window.Size
    , app : App.Model
    }


type Msg
    = OnWindowResizes Window.Size
    | OnAppMsg App.Msg


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        ( appModel, appCmd ) =
            App.init
    in
    ( { windowSize = { width = 1, height = 1 }
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
        OnWindowResizes windowSize ->
            ( { model | windowSize = windowSize }, Cmd.none )

        OnAppMsg nestedMsg ->
            let
                ( appModel, appCmd ) =
                    App.update nestedMsg model.app
            in
            ( { model | app = appModel }, Cmd.map OnAppMsg appCmd )


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
        [ Window.resizes OnWindowResizes
        , App.subscriptions model.app |> Sub.map OnAppMsg
        ]


main =
    Html.programWithFlags
        { view = view
        , subscriptions = subscriptions
        , update = update
        , init = init
        }
