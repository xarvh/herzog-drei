module MainScene exposing (..)

import Bot.Dummy
import ColorPattern exposing (ColorPattern)
import Config exposing (Config)
import Dict exposing (Dict)
import Game exposing (..)
import Gamepad exposing (Gamepad)
import GamepadPort
import Html exposing (..)
import Html.Attributes exposing (class, style)
import Init
import Input
import Math.Vector2 as Vec2 exposing (Vec2, vec2)
import Mech
import Random exposing (Generator)
import Set exposing (Set)
import Shell exposing (Shell)
import SplitScreen exposing (Viewport)
import Update
import View.Game


type alias Model =
    { game : Game
    , botStatesByKey : Dict String Bot.Dummy.State
    , fps : List Float
    , previousInputStatesByKey : Dict String InputState
    }



-- init


initDemo : Random.Seed -> ValidatedMap -> Model
initDemo seed map =
    let
        game =
            makeAiGame seed map
    in
    { game = game
    , botStatesByKey = Dict.empty
    , fps = [ 1 ]
    , previousInputStatesByKey = Dict.empty
    }
        |> initBots


initTeamSelection : Random.Seed -> ValidatedMap -> Model
initTeamSelection seed map =
    { game = Init.asTeamSelection seed map
    , botStatesByKey = Dict.empty
    , fps = [ 1 ]
    , previousInputStatesByKey = Dict.empty
    }



-- input stuff


inputKeyboardAndMouseKey : String
inputKeyboardAndMouseKey =
    "keyboard+mouse"


inputGamepadKey : Int -> String
inputGamepadKey index =
    "gamepad " ++ String.fromInt index


inputKeyIsHuman : String -> Bool
inputKeyIsHuman key =
    inputIsBot key |> not


inputBot : TeamId -> Int -> InputKey
inputBot teamId n =
    let
        t =
            case teamId of
                TeamLeft ->
                    "L"

                TeamRight ->
                    "R"
    in
    "bot " ++ t ++ String.fromInt n


inputIsBot : InputKey -> Bool
inputIsBot key =
    String.startsWith "bot " key



-- Input: Gamepads


threshold : Vec2 -> Vec2
threshold v =
    if Vec2.length v > 0.1 then
        v
    else
        vec2 0 0


gamepadToInput : Gamepad -> ( String, InputState )
gamepadToInput gamepad =
    let
        isPressed =
            Gamepad.isPressed gamepad
    in
    ( "gamepad " ++ String.fromInt (Gamepad.getIndex gamepad)
    , { aim = Gamepad.rightStickPosition gamepad |> Vec2.fromRecord |> threshold |> AimAbsolute
      , fire = isPressed Gamepad.RightBumper || isPressed Gamepad.RightTrigger || isPressed Gamepad.RightStickPress
      , transform = isPressed Gamepad.A
      , switchUnit = False
      , rally = isPressed Gamepad.B
      , move = Gamepad.leftStickPosition gamepad |> Vec2.fromRecord |> threshold
      }
    )



-- Input: Keyboard & Mouse


getKeyboardAndMouseInputState : Shell -> Model -> InputState
getKeyboardAndMouseInputState shell model =
    let
        move =
            Input.arrowsAndWasd shell.pressedKeys

        isPressed key =
            Set.member key shell.pressedKeys

        mouseAim =
            SplitScreen.mouseScreenToViewport shell.mousePosition shell.viewport
                |> (\( xx, yy ) -> vec2 xx yy)
                |> Vec2.scale (View.Game.tilesToViewport model.game shell.viewport)
                |> AimRelative
    in
    { aim = mouseAim
    , fire = shell.mouseIsPressed
    , transform = isPressed "E"
    , switchUnit = isPressed " "
    , rally = isPressed "Q"
    , move = move
    }



-- Input: Bots


allBotsThink : Model -> ( Dict String Bot.Dummy.State, Dict String InputState )
allBotsThink model =
    let
        foldBot : String -> Bot.Dummy.State -> ( Dict String Bot.Dummy.State, Dict String InputState ) -> ( Dict String Bot.Dummy.State, Dict String InputState )
        foldBot inputSourceKey oldState ( statesByKey, inputsByKey ) =
            let
                ( newState, input ) =
                    Bot.Dummy.update model.game oldState
            in
            ( Dict.insert inputSourceKey newState statesByKey, Dict.insert inputSourceKey input inputsByKey )
    in
    Dict.foldl foldBot ( Dict.empty, Dict.empty ) model.botStatesByKey


initBots : Model -> Model
initBots model =
    let
        humanInputs team =
            team.mechClassByInputKey
                |> Dict.keys
                |> List.filter (inputIsBot >> not)

        initBot : String -> Team -> Int -> Game -> Bot.Dummy.State
        initBot inputKey team n game =
            Bot.Dummy.init inputKey team.id (humanInputs team /= []) n game

        addBot : Team -> String -> Dict String Bot.Dummy.State -> Dict String Bot.Dummy.State
        addBot team inputKey botStatesByKey =
            Dict.insert
                inputKey
                (initBot inputKey team (Dict.size botStatesByKey) model.game)
                botStatesByKey

        teamBots : Team -> Dict String Bot.Dummy.State
        teamBots team =
            team.mechClassByInputKey
                |> Dict.keys
                |> List.filter inputIsBot
                |> List.foldl (addBot team) Dict.empty
    in
    { model | botStatesByKey = Dict.union (teamBots model.game.leftTeam) (teamBots model.game.rightTeam) }



-- AI vs AI game to run in the background


makeAiGame : Random.Seed -> ValidatedMap -> Game
makeAiGame seed map =
    let
        makeTeam : TeamId -> ColorPattern -> List MechClass -> TeamSeed
        makeTeam id colorPattern classes =
            { colorPattern = colorPattern
            , mechClassByInputKey =
                classes
                    |> List.indexedMap (\index class -> ( inputBot id index, class ))
                    |> Dict.fromList
            }

        tuplesToTeam ( color1, color2 ) ( classes1, classes2 ) =
            ( makeTeam TeamLeft color1 classes1, makeTeam TeamRight color2 classes2 )

        generateMechClasses : Int -> Generator ( List MechClass, List MechClass )
        generateMechClasses playersPerTeam =
            Random.pair
                (Random.list playersPerTeam Mech.classGenerator)
                (Random.list playersPerTeam Mech.classGenerator)

        generateTeams =
            Random.map2 tuplesToTeam
                ColorPattern.twoDifferent
                (Random.int 1 4 |> Random.andThen generateMechClasses)

        ( ( leftTeam, rightTeam ), newSeed ) =
            Random.step generateTeams seed
    in
    Init.asVersus newSeed 0 leftTeam rightTeam map



-- Update


noCmd : Model -> ( Model, Cmd a )
noCmd model =
    ( model, Cmd.none )


updateOnGamepad : Gamepad.Blob -> Shell -> Model -> ( Model, Cmd a )
updateOnGamepad gamepadBlob shell model =
    let
        dtInMilliseconds =
            Gamepad.animationFrameDelta gamepadBlob

        gamepadsInputByKey =
            gamepadBlob
                |> Gamepad.getGamepads shell.config.gamepadDatabase
                |> List.map gamepadToInput
                |> Dict.fromList

        keyAndMouse =
            if shell.config.useKeyboardAndMouse || Dict.size gamepadsInputByKey == 0 then
                Dict.singleton inputKeyboardAndMouseKey (getKeyboardAndMouseInputState shell model)
            else
                Dict.empty

        ( botStatesByKey, botInputsByKey ) =
            allBotsThink model

        inputStatesByKey =
            botInputsByKey
                |> Dict.union gamepadsInputByKey
                |> Dict.union keyAndMouse
                |> Dict.map sanitizeInputState

        pairInputStateWithPrevious : String -> InputState -> ( InputState, InputState )
        pairInputStateWithPrevious inputKey currentInputState =
            case Dict.get inputKey model.previousInputStatesByKey of
                Just previousInputState ->
                    ( previousInputState, currentInputState )

                Nothing ->
                    -- Assume that state did not change
                    ( currentInputState, currentInputState )

        pairedInputStates =
            Dict.map pairInputStateWithPrevious inputStatesByKey

        -- All times in the game are in seconds
        dt =
            dtInMilliseconds / 1000

        ( game, outcomes ) =
            if shell.gameIsPaused then
                ( model.game, [] )
            else
                Update.update dt pairedInputStates model.game

        newModel =
            { model
                | game = game
                , botStatesByKey = botStatesByKey
                , fps = (1 / dt) :: List.take 120 model.fps
                , previousInputStatesByKey = inputStatesByKey
            }
    in
    List.foldl applyOutcome ( newModel, [] ) outcomes
        |> Tuple.mapSecond Cmd.batch


sanitizeInputState : InputKey -> InputState -> InputState
sanitizeInputState inputKey inputState =
    let
        vecNoNaN v =
            let
                { x, y } =
                    Vec2.toRecord v
            in
            if isNaN x || isNaN y then
                let
                    unused =
                        Debug.log "input is NaN" ( inputKey, inputState )
                in
                vec2 0 0
            else
                v

        aim =
            case inputState.aim of
                AimAbsolute v ->
                    v |> vecNoNaN |> AimAbsolute

                AimRelative v ->
                    v |> vecNoNaN |> AimRelative
    in
    { inputState | aim = aim, move = vecNoNaN inputState.move }


applyOutcome : Outcome -> ( Model, List (Cmd a) ) -> ( Model, List (Cmd a) )
applyOutcome outcome ( model, cmds ) =
    case outcome of
        OutcomeCanAddBots ->
            ( addBots model, cmds )

        OutcomeCanInitBots ->
            ( initBots model, cmds )


addBots : Model -> Model
addBots model =
    let
        left =
            model.game.leftTeam.mechClassByInputKey

        right =
            model.game.rightTeam.mechClassByInputKey

        teamsSize =
            max (Dict.size left) (Dict.size right)

        ( ( leftBots, rightBots ), seed ) =
            Random.pair
                (Random.list (teamsSize - Dict.size left) Mech.classGenerator)
                (Random.list (teamsSize - Dict.size right) Mech.classGenerator)
                |> (\generator -> Random.step generator model.game.seed)

        game =
            model.game
                |> updateTeam (addPlayers leftBots model.game.leftTeam)
                |> updateTeam (addPlayers rightBots model.game.rightTeam)
                |> (\g -> { g | seed = seed })
    in
    { model | game = game }


addPlayers : List MechClass -> Team -> Team
addPlayers botClasses team =
    let
        bots =
            botClasses
                |> List.indexedMap (\index mechClass -> ( inputBot team.id index, mechClass ))
                |> Dict.fromList
    in
    { team | mechClassByInputKey = Dict.union team.mechClassByInputKey bots }



-- View


view : Shell -> Model -> List (Html a)
view shell model =
    [ div
        [ class "game-area" ]
        -- TODO rename to scene-area
        [ SplitScreen.viewportsWrapper
            [ View.Game.view shell.viewport model.game ]
        ]
    , viewFps model shell
    , viewVictory shell.viewport model.game
    ]


viewFps : Model -> Shell -> Html a
viewFps model shell =
    if not shell.config.showFps then
        text ""
    else
        let
            fps =
                List.sum model.fps / toFloat (List.length model.fps) |> round
        in
        div
            [ class "fps nonSelectable" ]
            [ text ("FPS " ++ String.fromInt fps) ]


viewVictory : Viewport -> Game -> Html a
viewVictory viewport game =
    case game.maybeVictory of
        Nothing ->
            text ""

        Just ( teamId, victoryTime ) ->
            let
                team =
                    getTeam game teamId

                size =
                    min viewport.w viewport.h |> toFloat

                toPx f =
                    (size * f |> String.fromFloat) ++ "px"

                pattern =
                    team.colorPattern

                dt =
                    game.time - victoryTime

                fadeInDuration =
                    1

                opacity =
                    dt / fadeInDuration |> min 1
            in
            div
                [ class "fullWindow flex justifyCenter academy"
                ]
                [ span
                    [ class "nonSelectable mt2"
                    , style "   -moz-text-fill-color" pattern.bright
                    , style "-webkit-text-fill-color" pattern.bright
                    , style "   -moz-text-stroke-color" pattern.dark
                    , style "-webkit-text-stroke-color" pattern.dark
                    , style "   -moz-text-stroke-width" (toPx 0.0055)
                    , style "-webkit-text-stroke-width" (toPx 0.0055)
                    , style "font-size" (toPx 0.16)
                    , style "opacity" (String.fromFloat opacity)
                    ]
                    --TODO [ String.Extra.toTitleCase pattern.key ++ " wins!" |> text ]
                    [ pattern.key ++ " wins!" |> text ]
                ]
