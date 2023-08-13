module State.Ready exposing (Model, Msg, init, update, view)

import Action
import Data.Game as Game exposing (Game)
import Element exposing (Element)
import Element.Font as Font
import Framework
import Framework.Grid as Grid
import Random exposing (Generator, Seed)
import State.Playing as PlayingState
import View.Button
import View.Game as GameView
import View.Header as HeaderView
import View.Shade



----------------------
-- Model
----------------------


type alias State =
    Game


type alias Model =
    ( State, Seed )


type Msg
    = NormalModeSelected


type alias Action =
    Action.Action Model Msg PlayingState.TransitionData Never



----------------------
-- Init
----------------------


stateGenerator : Generator State
stateGenerator =
    Game.generator


init : Seed -> ( Model, Cmd Msg )
init seed =
    ( Random.step stateGenerator seed, Cmd.none )



----------------------
-- Update
----------------------


update : Msg -> Model -> Action
update msg ( game, seed ) =
    case msg of
        NormalModeSelected ->
            Action.transitioning
                { game = game
                , seed = seed
                }



----------------------
-- View
----------------------


view : Float -> msg -> (Msg -> msg) -> Model -> Element msg
view scale restartMsg msgMapper ( game, _ ) =
    [ HeaderView.view restartMsg game.score
    , GameView.viewHome scale game
    ]
        |> Element.column
            (Framework.container
                ++ [ [ [ Element.el
                            [ Font.size <| floor <| scale * 120
                            , Font.family
                                [ Font.typeface "Noto Emoji" ]
                            ]
                         <|
                            Element.text "🌍"
                       , Element.column
                            [ Font.size <| floor <| scale * 60
                            , Element.centerX
                            , Font.color <| Element.rgb255 255 255 255
                            , Font.center
                            ]
                         <|
                            [ Element.text "Little"
                            , Element.text "World"
                            , Element.text "Puzzler"
                            ]
                       ]
                        |> Element.row
                            (Grid.simple
                                ++ [ Element.width <| Element.shrink
                                   , Element.centerY
                                   , Element.centerX
                                   ]
                            )
                     , View.Button.textButton []
                        { label = "Play"
                        , onPress = NormalModeSelected |> msgMapper |> Just
                        }
                        |> Element.html
                        |> Element.el [ Element.centerX ]
                     ]
                        |> Element.column (Grid.simple ++ [ Element.height <| Element.fill ])
                        |> List.singleton
                        |> View.Shade.viewNormal []
                        |> Element.inFront
                   ]
            )
