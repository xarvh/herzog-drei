module SceneInit exposing (..)

import ColorPattern exposing (ColorPattern)





type alias Team =
  { players : List String
  , colorPattern : ColorPattern
  }



type Outcome
  = Continue Model
  | SwitchToGame Team Team


--

type alias Model =
  {}


init : Model
init = {}


--


update : Float -> Model -> (Model, Cmd a)
update time model =
  model







