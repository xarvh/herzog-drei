module App exposing (..)

import AnimationFrame
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Time exposing (Time)


-- Msg


type Msg
    = OnAnimationFrame Time



-- Model


type alias Model =
    String



-- Init


init : ( Model, Cmd Msg )
init =
    noCmd ""



-- Update


noCmd : Model -> ( Model, Cmd a )
noCmd model =
    ( model, Cmd.none )


update : Vec2 -> Msg -> Model -> ( Model, Cmd Msg )
update mousePosition msg model =
    case msg of
        OnAnimationFrame dt ->
            noCmd model



-- View


checkersBackground : Int -> Svg a
checkersBackground numberOfSquaresPerSide =
    let
        squareSize =
            1.0 / toFloat numberOfSquaresPerSide

        s =
            toString squareSize

        s2 =
            toString (squareSize * 2)
    in
    g
        []
        [ defs
            []
            [ pattern
                [ id "grid"
                , width s2
                , height s2
                , patternUnits "userSpaceOnUse"
                ]
                [ rect
                    [ x "0"
                    , y "0"
                    , width s
                    , height s
                    , fill "#eee"
                    ]
                    []
                , rect
                    [ x s
                    , y s
                    , width s
                    , height s
                    , fill "#eee"
                    ]
                    []
                ]
            ]
        , rect
            [ fill "url(#grid)"
            , x "-0.5"
            , y "-0.5"
            , width "1"
            , height "1"
            ]
            []
        ]


view : Model -> Svg Msg
view model =
    g
        []
        [ checkersBackground 10
        , circle [ cx "-0.5", cy "-0.5", r "0.1", fill "red" ] []
        , circle [ cx "-0.5", cy "0.5", r "0.1", fill "red" ] []
        , circle [ cx "0.5", cy "0.5", r "0.1", fill "red" ] []
        , circle [ cx "0.5", cy "-0.5", r "0.1", fill "red" ] []
        ]


subscriptions : Model -> Sub Msg
subscriptions model =
    AnimationFrame.diffs OnAnimationFrame
