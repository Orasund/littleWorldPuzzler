module State.Finished exposing (Model, Msg, TransitionData, init, view)

import Data.Game exposing (EndCondition(..), Game)
import Element exposing (Element)
import Element.Font as Font
import Element.Input as Input
import Firestore exposing (Error(..))
import Framework
import Framework.Button as Button
import Framework.Heading as Heading
import UndoList exposing (UndoList)
import View.Game as GameView
import View.Header as HeaderView
import View.Shade


type alias TransitionData =
    { game : Game
    , history : UndoList Game
    , challenge : Bool
    }


type alias Msg =
    ()



----------------------
-- Init
----------------------


init : TransitionData -> ( Model, Cmd Msg )
init { game, history, challenge } =
    ( End
        { game = game
        , history = history
        , challenge = challenge
        }
    , Cmd.none
    )



----------------------
-- Model
----------------------


type alias EndState =
    { game : Game
    , history : UndoList Game
    , challenge : Bool
    }


type Model
    = End EndState



----------------------
-- View
----------------------


viewScore : { restartMsg : msg } -> { score : Int } -> List (Element msg)
viewScore { restartMsg } { score } =
    [ Element.el (Heading.h2 ++ [ Element.centerX ]) <|
        Element.text <|
            "Game Over"
    , Element.el (Heading.h3 ++ [ Element.centerX ]) <|
        Element.text "Score"
    , Element.el (Heading.h1 ++ [ Element.centerX ]) <|
        Element.text <|
            String.fromInt <|
                score
    , Input.button
        (Button.simple
            ++ [ Font.family [ Font.sansSerif ]
               , Element.centerX
               , Font.color <| Element.rgb 0 0 0
               ]
        )
      <|
        { onPress = Just restartMsg
        , label = Element.text "Restart"
        }
    ]


view : Float -> msg -> (Msg -> msg) -> Model -> Element msg
view scale restartMsg _ model =
    let
        ({ score } as game) =
            case model of
                End m ->
                    m.game
    in
    [ HeaderView.view restartMsg game.score
    , GameView.viewFinished scale game
    ]
        |> Element.column
            (Framework.container
                ++ [ viewScore
                        { restartMsg = restartMsg
                        }
                        { score = score
                        }
                        |> View.Shade.viewWon []
                        |> Element.inFront
                   ]
            )
