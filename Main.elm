module Main exposing (..)

import App
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Keyboard
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Navigation
import Style
import Svg
import Svg.Attributes exposing (transform)
import Task
import View.Background


type alias Model =
    { app : App.Model
    , showConfig : Bool
    , useKeyboardAndMouse : Bool
    }


type Msg
    = Noop
    | OnAppMsg App.Msg
    | OnKeyPress Keyboard.KeyCode
    | OnToggleKeyboardAndMouse Bool


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
      , useKeyboardAndMouse = True
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

        OnToggleKeyboardAndMouse flag ->
            noCmd { model | useKeyboardAndMouse = flag }


view : Model -> Html Msg
view model =
    App.view model.app |> Html.map OnAppMsg


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
