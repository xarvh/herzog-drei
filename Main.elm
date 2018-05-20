module Main exposing (..)

import App
import Dict exposing (Dict)
import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Keyboard.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Navigation
import Svg exposing (g, svg)
import Svg.Attributes exposing (transform)
import Task
import View.Background


type alias Flags =
    { gamepadDatabaseAsString : String
    , gamepadDatabaseKey : String
    , dateNow : Int
    }


type alias Model =
    { app : App.Model
    , pressedKeys : List Keyboard.Extra.Key
    }


type Msg
    = OnAppMsg App.Msg
    | OnKeyboardMsg Keyboard.Extra.Msg
    | Noop


stringToTuple : String -> Maybe ( String, String )
stringToTuple str =
    case String.split "=" str of
        key :: values ->
            Just ( key, String.join "=" values )

        _ ->
            Nothing


init : Flags -> Navigation.Location -> ( Model, Cmd Msg )
init flags location =
    let
        params =
            location.hash
                |> String.dropLeft 1
                |> String.split "&"
                |> List.filterMap stringToTuple
                |> Dict.fromList

        ( appModel, appCmd ) =
            App.init params
    in
    ( { pressedKeys = []
      , app = appModel
      }
    , appCmd |> Cmd.map OnAppMsg
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Noop ->
            ( model, Cmd.none )

        OnAppMsg nestedMsg ->
            let
                ( appModel, appCmd ) =
                    App.update model.pressedKeys nestedMsg model.app
            in
            ( { model | app = appModel }, Cmd.map OnAppMsg appCmd )

        OnKeyboardMsg keyboardMsg ->
            ( { model | pressedKeys = Keyboard.Extra.update keyboardMsg model.pressedKeys }, Cmd.none )


view : Model -> Html Msg
view model =
    div
        []
        [ Html.node "style"
            []
            [ Html.text View.Background.classAndAnimation
            ]
        , App.view model.app
            |> Svg.map OnAppMsg
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ App.subscriptions model.app |> Sub.map OnAppMsg
        , Sub.map OnKeyboardMsg Keyboard.Extra.subscriptions
        ]


main =
    Navigation.programWithFlags
        (always Noop)
        { view = view
        , subscriptions = subscriptions
        , update = update
        , init = init
        }
