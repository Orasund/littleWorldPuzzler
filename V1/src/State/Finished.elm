module State.Finished exposing (Model, Msg, TransitionData, init, view)

import Data.Game exposing (EndCondition(..), Game)
import Element exposing (Element)
import Framework
import Html exposing (Html)
import Html.Attributes
import Layout
import View.Button
import View.Game as GameView
import View.Header as HeaderView
import View.Shade


type alias TransitionData =
    { game : Game
    }


type alias Msg =
    ()



----------------------
-- Init
----------------------


init : TransitionData -> ( Model, Cmd Msg )
init { game } =
    ( End
        { game = game
        }
    , Cmd.none
    )



----------------------
-- Model
----------------------


type alias EndState =
    { game : Game
    }


type Model
    = End EndState



----------------------
-- View
----------------------


viewScore : { restartMsg : msg } -> { score : Int } -> Html msg
viewScore { restartMsg } { score } =
    [ "Game Over" |> Layout.text [ Html.Attributes.style "font-size" "2rem" ]
    , "Score" |> Layout.text [ Html.Attributes.style "font-size" "2rem" ]
    , score |> String.fromInt |> Layout.text [ Html.Attributes.style "font-size" "3rem" ]
    , View.Button.textButton [ Html.Attributes.style "font-family" "sans-serif" ] <|
        { onPress = Just restartMsg
        , label = "Restart"
        }
    ]
        |> Layout.column []


view : Float -> msg -> (Msg -> msg) -> Model -> Element msg
view scale restartMsg _ model =
    let
        ({ score } as game) =
            case model of
                End m ->
                    m.game
    in
    [ HeaderView.view restartMsg game.score |> Element.html
    , GameView.viewFinished scale game
    ]
        |> Element.column
            (Framework.container
                ++ [ viewScore
                        { restartMsg = restartMsg
                        }
                        { score = score
                        }
                        |> View.Shade.success []
                        |> Element.html
                        |> Element.inFront
                   ]
            )
