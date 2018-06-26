module Input exposing (..)

import Json.Decode exposing (Decoder)
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Set exposing (Set)


mouseMoveDecoder : (Int -> Int -> msg) -> Decoder msg
mouseMoveDecoder msg =
    Json.Decode.map2 msg
        (Json.Decode.field "clientX" Json.Decode.int)
        (Json.Decode.field "clientY" Json.Decode.int)


keyboardDecoder : (String -> msg) -> Decoder msg
keyboardDecoder msg =
    Json.Decode.string
        |> Json.Decode.field "key"
        |> Json.Decode.map (singleToUpper >> msg)


singleToUpper : String -> String
singleToUpper s =
    if String.length s /= 1 then
        s
    else
        String.toUpper s


arrowsAndWasd : Set String -> Vec2
arrowsAndWasd pressedKeys =
    let
        fold : ( Vec2, List String ) -> Vec2 -> Vec2
        fold ( v, names ) accum =
            if List.any (\n -> Set.member n pressedKeys) names then
                Vec2.add v accum
            else
                accum
    in
    [ ( vec2 0 1, [ "W", "ArrowUp" ] )
    , ( vec2 0 -1, [ "S", "ArrowDown" ] )
    , ( vec2 1 0, [ "D", "ArrowRight" ] )
    , ( vec2 -1 0, [ "A", "ArrowLeft" ] )
    ]
        |> List.foldl fold (vec2 0 0)
