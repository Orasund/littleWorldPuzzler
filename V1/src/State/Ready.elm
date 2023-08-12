module State.Ready exposing (Model, Msg, init, update, view)

import Action
import Data.Game as Game exposing (Game)
import Element exposing (Element)
import Element.Font as Font
import Element.Input as Input
import Framework
import Framework.Button as Button
import Framework.Card as Card
import Framework.Grid as Grid
import Framework.Heading as Heading
import Random exposing (Generator, Seed)
import State.Playing as PlayingState exposing (Mode(..))
import Time exposing (Month(..))
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
                , mode = Normal
                }



----------------------
-- View
----------------------


viewMode : msg -> { title : String, desc : String } -> Element msg
viewMode msg { title, desc } =
    Input.button
        (Button.simple
            ++ Card.large
            ++ [ Font.family
                    [ Font.sansSerif ]
               , Element.centerX
               , Element.centerY
               , Font.color <| Element.rgb255 0 0 0
               ]
        )
    <|
        { onPress = Just msg
        , label =
            Element.column
                Grid.spaceEvenly
            <|
                [ Element.paragraph
                    (Heading.h2 ++ [ Element.centerX ])
                  <|
                    List.singleton <|
                        Element.text title
                , Element.paragraph [] <|
                    List.singleton <|
                        Element.text desc
                ]
        }


view : Float -> msg -> (Msg -> msg) -> Model -> Element msg
view scale restartMsg msgMapper ( game, _ ) =
    [ HeaderView.view scale restartMsg game.score
    , GameView.viewHome scale game
    ]
        |> Element.column
            (Framework.container
                ++ [ [ Element.wrappedRow (Grid.simple ++ [ Element.height <| Element.fill ])
                        [ Element.row
                            (Grid.simple
                                ++ [ Element.width <| Element.shrink
                                   , Element.centerY
                                   ]
                            )
                            [ Element.el
                                [ Font.size <| floor <| scale * 150
                                , Font.family
                                    [ Font.typeface "Noto Emoji" ]
                                ]
                              <|
                                Element.text "🌍"
                            , Element.column
                                [ Font.size <| floor <| scale * 80
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
                        , Element.column (Grid.simple ++ [ Element.centerY ]) <|
                            [ viewMode
                                (msgMapper <| NormalModeSelected)
                                { title = "Play"
                                , desc = ""
                                }
                            ]
                        ]
                     ]
                        |> View.Shade.viewNormal []
                        |> Element.inFront
                   ]
            )
