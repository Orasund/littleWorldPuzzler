module Main exposing (..)

import Browser exposing (Document)
import Card exposing (Card)
import Config
import Deck exposing (Deck, DeckId)
import Dict
import Game exposing (Effect(..), Game)
import Html
import Html.Attributes
import Html.Events
import Layout
import Random exposing (Seed)
import Round exposing (CardId)
import Set exposing (Set)
import View
import View.CardArea
import View.Tab


type Overlay
    = GameWonOverlay { score : Int }
    | GameLostOverlay { turnsLeft : Int }


type alias Model =
    { game : Game
    , lastCardPlayed : Maybe CardId
    , selectedInfoTab : Maybe Card
    , overlay : Maybe Overlay
    , decksWon : Set DeckId
    , seed : Seed
    }


type Msg
    = ClickedAt ( Int, Int )
    | SwapCards
    | BoughtPack Deck
    | SelectTabInfo Card
    | CloseOverlay
    | Restart Seed


init : () -> ( Model, Cmd Msg )
init () =
    ( { game = Game.init
      , lastCardPlayed = Nothing
      , selectedInfoTab = Nothing
      , overlay = Nothing
      , decksWon = Set.empty
      , seed = Random.initialSeed 42
      }
    , Random.generate Restart Random.independentSeed
    )


view : Model -> Document Msg
view model =
    { title = "Little World Puzzler 2"
    , body =
        [ (case model.game.round of
            Just round ->
                [ [ "Points: "
                        ++ String.fromInt model.game.totalPoints
                        ++ " + "
                        ++ String.fromInt round.points
                        |> Layout.text []
                  , "Turns left:"
                        ++ String.fromInt round.turns
                        |> Layout.text []
                  , View.button (Just (Restart model.seed)) "Restart"
                  ]
                    |> Layout.row
                        [ Layout.contentWithSpaceBetween
                        , Html.Attributes.style "width" "100%"
                        ]
                , [ List.range 0 (Config.worldSize - 1)
                        |> List.map
                            (\y ->
                                List.range 0 (Config.worldSize - 1)
                                    |> List.map
                                        (\x ->
                                            round.world
                                                |> Dict.get ( x, y )
                                                |> (\maybeCard ->
                                                        View.cell
                                                            { clicked = ClickedAt ( x, y )
                                                            , neighbors =
                                                                Round.neighborsOf ( x, y )
                                                                    |> List.filterMap
                                                                        (\p -> Dict.get p round.world)
                                                            }
                                                            maybeCard
                                                   )
                                        )
                                    |> Layout.row [ Layout.gap 8 ]
                            )
                        |> Layout.column [ Layout.gap 8, Layout.alignAtCenter ]
                  , View.Tab.toHtml
                        { round = round
                        , onSelect = SelectTabInfo
                        }
                        model.selectedInfoTab
                  ]
                    |> Layout.column
                        [ Layout.fill
                        , Layout.contentWithSpaceBetween
                        ]
                , model.game.round
                    |> Maybe.map
                        (View.CardArea.toHtml
                            { onSwapCards = SwapCards
                            , lastSelectedCard = model.lastCardPlayed
                            }
                            []
                        )
                    |> Maybe.withDefault Layout.none
                ]

            Nothing ->
                [ [ "Points: "
                        ++ String.fromInt model.game.totalPoints
                        |> Layout.text []
                  , View.button (Just (Restart model.seed)) "Restart"
                  ]
                    |> Layout.row
                        [ Layout.contentWithSpaceBetween
                        , Html.Attributes.style "width" "100%"
                        ]
                , [ "Choose a Pack" |> Layout.text []
                  , Deck.asList
                        |> List.map
                            (\pack ->
                                [ (if model.decksWon |> Set.member (Deck.toString pack) then
                                    "✅"

                                   else
                                    ""
                                  )
                                    ++ "Play for "
                                    ++ String.fromInt (Deck.price pack)
                                    |> Layout.text []
                                , pack |> View.viewPack
                                ]
                                    |> Layout.column
                                        (Layout.asButton
                                            { label = "Play for " ++ String.fromInt (Deck.price pack)
                                            , onPress = Just (BoughtPack pack)
                                            }
                                            ++ [ Layout.alignAtCenter
                                               , Layout.contentAtStart
                                               ]
                                        )
                            )
                        |> Layout.row [ Layout.gap 8 ]
                  ]
                    |> Layout.column
                        [ Layout.fill
                        , Layout.contentWithSpaceBetween
                        ]
                ]
          )
            |> Layout.column
                ([ Layout.gap 16
                 , Html.Attributes.style "width" "400px"
                 , Html.Attributes.style "height" "600px"
                 , Html.Attributes.style "border" "1px solid rgba(0,0,0,0.2)"
                 , Html.Attributes.style "border-radius" "16px"
                 , Html.Attributes.style "padding" "32px"
                 ]
                    ++ Layout.centered
                )
            |> Layout.withStack
                (Html.Attributes.style "height" "100%"
                    :: Layout.centered
                )
                (case model.overlay of
                    Just (GameWonOverlay args) ->
                        [ \attrs ->
                            [ "🎉" |> Layout.text [ Html.Attributes.style "font-size" "40px" ]
                            , "You win"
                                |> Layout.text
                                    [ Html.Attributes.style "font-size" "20px"
                                    ]
                            , "Score" |> Layout.text []
                            , String.fromInt args.score |> Layout.text [ Html.Attributes.style "font-size" "120px" ]
                            ]
                                |> View.overlay
                                    (Html.Events.onClick CloseOverlay
                                        :: attrs
                                    )
                        ]

                    Just (GameLostOverlay args) ->
                        [ \attrs ->
                            [ "☠️" |> Layout.text [ Html.Attributes.style "font-size" "40px" ]
                            , "Game Over"
                                |> Layout.text
                                    [ Html.Attributes.style "font-size" "20px"
                                    ]
                            , "You just needed to survive " |> Layout.text []
                            , args.turnsLeft
                                |> String.fromInt
                                |> Layout.text [ Html.Attributes.style "font-size" "120px" ]
                            , " more "
                                ++ (if args.turnsLeft == 1 then
                                        "turn"

                                    else
                                        "turns"
                                   )
                                |> Layout.text []
                            ]
                                |> View.overlay
                                    (Html.Events.onClick CloseOverlay
                                        :: attrs
                                    )
                        ]

                    Nothing ->
                        []
                )
        , Html.node "style" [] [ Html.text """
:root, body {
    height: 100%
} 

button:hover {
    filter: brightness(0.95)
}

button:focus {
    filter: brightness(0.90)
}

button:active {
    filter: brightness(0.7)
}
""" ]
        ]
    }


applyEffect : Effect -> Model -> Model
applyEffect effect model =
    case effect of
        GameWon args ->
            { model
                | overlay =
                    { score = args.score }
                        |> GameWonOverlay
                        |> Just
                , decksWon =
                    model.decksWon
                        |> Set.insert (Deck.toString args.deck)
            }

        GameLost args ->
            { model
                | overlay =
                    { turnsLeft = args.turnsLeft }
                        |> GameLostOverlay
                        |> Just
            }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedAt pos ->
            ( model.seed
                |> Random.step (Game.placeCard pos model.game)
                |> (\( ( game, effects ), seed ) ->
                        effects
                            |> List.foldl applyEffect
                                { model
                                    | game = game
                                    , seed = seed
                                    , lastCardPlayed =
                                        model.game.round
                                            |> Maybe.andThen .selected
                                    , selectedInfoTab =
                                        model.game.round
                                            |> Maybe.andThen Round.getSelected
                                            |> Maybe.map Tuple.second
                                }
                   )
            , Cmd.none
            )

        SwapCards ->
            Random.step (Game.swapCards model.game) model.seed
                |> (\( game, seed ) ->
                        ( { model | game = game, seed = seed }
                        , Cmd.none
                        )
                   )

        SelectTabInfo card ->
            ( { model | selectedInfoTab = Just card }
            , Cmd.none
            )

        BoughtPack pack ->
            model.game
                |> Game.buyPack pack
                |> Maybe.map (\gen -> Random.step gen model.seed)
                |> Maybe.map
                    (\( game, seed ) ->
                        ( { model
                            | game = game
                            , seed = seed
                            , selectedInfoTab =
                                game.round
                                    |> Maybe.andThen Round.getSelected
                                    |> Maybe.map Tuple.second
                          }
                        , Cmd.none
                        )
                    )
                |> Maybe.withDefault ( model, Cmd.none )

        CloseOverlay ->
            ( { model | overlay = Nothing }
            , Cmd.none
            )

        Restart initialSeed ->
            ( { model
                | game = Game.init
                , seed = initialSeed
              }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
