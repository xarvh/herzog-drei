module Main exposing (..)

import App
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (class)
import Keyboard
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Navigation
import Svg
import Svg.Attributes exposing (transform)
import Task
import View.Background


type alias Model =
    { app : App.Model
    , showConfig : Bool
    }


type Msg
    = Noop
    | OnAppMsg App.Msg
    | OnKeyPress Keyboard.KeyCode


stringToTuple : String -> Maybe ( String, String )
stringToTuple str =
    case String.split "=" str of
        key :: values ->
            Just ( key, String.join "=" values )

        _ ->
            Nothing


init : App.Flags -> Navigation.Location -> ( Model, Cmd Msg )
init flags location =
    let
        params =
            location.hash
                |> String.dropLeft 1
                |> String.split "&"
                |> List.filterMap stringToTuple
                |> Dict.fromList

        ( appModel, appCmd ) =
            App.init params flags
    in
    ( { showConfig = False
      , app = appModel
      }
    , appCmd |> Cmd.map OnAppMsg
    )


noCmd : Model -> ( Model, Cmd Msg )
noCmd model =
    ( model, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            noCmd model

        OnAppMsg nestedMsg ->
            let
                ( appModel, appCmd ) =
                    App.update nestedMsg model.app
            in
            ( { model | app = appModel }, Cmd.map OnAppMsg appCmd )

        OnKeyPress keyCode ->
            case keyCode of
                27 ->
                    noCmd { model | showConfig = not model.showConfig }

                _ ->
                    noCmd model



--


globalStyle =
    """
  .flex { display: flex; }
  .flex1 { flex: 1; }
  .alignCenter { align-items: center; }
  .alignEnd { align-items: flex-end; }
  .justifyCenter { justify-content: center; }
  .justifyBetween { justify-content: space-between; }

  .relative { position: relative; }
  .fullWindow { position: absolute; top: 0; left: 0; width: 100%; height: 100%; }

  .bgConfig { background-color: white; }
  .borderConfig { border: 1px solid black; }

  /* padding */
  .p2 { padding: 2em; }
  .pt2 { padding-top: 2em; }
  .pr2 { padding-right: 2em; }
  .pb2 { padding-bottom: 2em; }
  .pl2 { padding-left: 2em; }


  /* margin */
  .m1 { margin: 1em; }
  .mt1 { margin-top: 1em; }
  .mr1 { margin-right: 1em; }
  .mb1 { margin-bottom: 1em; }
  .ml1 { margin-left: 1em; }

  .m2 { margin: 2em; }
  .mt2 { margin-top: 2em; }
  .mr2 { margin-right: 2em; }
  .mb2 { margin-bottom: 2em; }
  .ml2 { margin-left: 2em; }
  """


viewConfig : Model -> Html Msg
viewConfig model =
    div
        [ class "fullWindow flex alignCenter justifyCenter"
        ]
        [ div
            [ class "bgConfig borderConfig p2" ]
            [ text "LOL" ]
        ]


view : Model -> Html Msg
view model =
    div
        [ class "relative" ]
        [ Html.node "style"
            []
            [ text "body { margin: 0; }"
            , text View.Background.classAndAnimation
            , text globalStyle
            ]
        , App.view model.app
            |> Svg.map OnAppMsg
        , if model.showConfig then
            viewConfig model
          else
            text ""
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ App.subscriptions model.app |> Sub.map OnAppMsg
        , Keyboard.ups OnKeyPress
        ]


main =
    Navigation.programWithFlags
        (always Noop)
        { view = view
        , subscriptions = subscriptions
        , update = update
        , init = init
        }
