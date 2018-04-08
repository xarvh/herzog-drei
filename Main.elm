module Main exposing (..)

import App
import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Keyboard.Extra
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Svg exposing (g, svg)
import Svg.Attributes exposing (transform)
import Task


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


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        ( appModel, appCmd ) =
            App.init
    in
    ( { pressedKeys = []
      , app = appModel
      }
    , appCmd |> Cmd.map OnAppMsg
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
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
    App.view model.app |> Svg.map OnAppMsg


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ App.subscriptions model.app |> Sub.map OnAppMsg
        , Sub.map OnKeyboardMsg Keyboard.Extra.subscriptions
        ]


main =
    Html.programWithFlags
        { view = view
        , subscriptions = subscriptions
        , update = update
        , init = init
        }
