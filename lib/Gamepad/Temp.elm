
--
-- Mapping helpers
--
-- This code is used to get an estimate of the buttons/sticks the user is
-- moving given a time series of RawGamepad states
--


{-| Buttons are always provided as a (isPressed, value) tuple.
This function ignores one and uses only and always the other.

Is this a good assumption?
Are there cases where both should be considered?

-}
boolToNumber : Bool -> number
boolToNumber bool =
    if bool then
        1
    else
        0


buttonToEstimate : Int -> ( Bool, Float ) -> ( Origin, Float )
buttonToEstimate originIndex ( pressed, value ) =
    ( Origin False Button originIndex, boolToNumber pressed )


axisToEstimate : Int -> Float -> ( Origin, Float )
axisToEstimate originIndex value =
    ( Origin (value < 0) Axis originIndex, abs value )


estimateThreshold : ( Origin, Float ) -> Maybe Origin
estimateThreshold ( origin, confidence ) =
    if confidence < 0.5 then
        Nothing
    else
        Just origin


{-| This function guesses the Origin currently activated by the user.
-}
estimateOrigin : UnknownGamepad -> Maybe Origin
estimateOrigin (UnknownGamepad rawGamepad) =
    let
        axesEstimates =
            Array.indexedMap axisToEstimate rawGamepad.axes

        buttonsEstimates =
            Array.indexedMap buttonToEstimate rawGamepad.buttons
    in
    Array.append axesEstimates buttonsEstimates
        |> Array.toList
        |> List.sortBy Tuple.second
        |> List.reverse
        |> List.head
        |> Maybe.andThen estimateThreshold
