module Main exposing (..)

import Browser exposing (Document)
import Config
import Dict
import Game exposing (Effect(..), Game, Overlay(..))
import Html
import Html.Attributes
import Html.Events
import Layout
import Pack exposing (Pack)
import Random exposing (Seed)
import Round
import View


type alias Model =
    { game : Game
    , overlay : Maybe Overlay
    , seed : Seed
    }


type Msg
    = ClickedAt ( Int, Int )
    | SwapCards
    | BoughtPack Pack
    | CloseOverlay
    | Restart Seed


init : () -> ( Model, Cmd Msg )
init () =
    ( { game = Game.init
      , overlay = Nothing
      , seed = Random.initialSeed 42
      }
    , Random.generate Restart Random.independentSeed
    )


view : Model -> Document Msg
view model =
    { title = "Little World Puzzler"
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
                        |> Layout.column [ Layout.gap 8 ]
                  , round.selected
                        |> Maybe.map
                            (View.description
                                [ Html.Attributes.style "bottom" "-100px"
                                , Html.Attributes.style "left" (String.fromFloat (Config.cardWidth * 1.5 + 5) ++ "px")
                                , Html.Attributes.style "width" "200px"
                                , Html.Attributes.style "border" "1px dashed rgba(0,0,0,0.2)"
                                , Html.Attributes.style "padding" "8px"
                                ]
                            )
                        |> Maybe.withDefault Layout.none
                  ]
                    |> Layout.column
                        [ Layout.fill
                        , Layout.contentWithSpaceBetween
                        ]
                , [ [ "Click to swap" |> Layout.text []
                    , round.backpack
                        |> Maybe.map (View.viewCard [])
                        |> Maybe.withDefault
                            ("Backpack"
                                |> View.viewEmptyCard
                            )
                        |> Layout.el (Layout.asButton { onPress = Just SwapCards, label = "swap cards" })
                    ]
                        |> Layout.column [ Html.Attributes.style "width" (String.fromFloat Config.cardWidth ++ "px") ]
                  , round.selected
                        |> Maybe.map (View.viewCard [])
                        |> Maybe.withDefault Layout.none
                  , round.deck
                        |> View.deck round.pack
                  ]
                    |> Layout.row
                        [ Layout.contentWithSpaceBetween
                        , Html.Attributes.style "width" "100%"
                        , Layout.alignAtEnd
                        ]
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
                  , Pack.asList
                        |> List.map
                            (\pack ->
                                [ "Play for "
                                    ++ String.fromInt (Pack.price pack)
                                    |> Layout.text []
                                , pack |> View.viewPack
                                ]
                                    |> Layout.column
                                        (Layout.asButton
                                            { label = "Play for " ++ String.fromInt (Pack.price pack)
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
                    Just (Game.GameWon args) ->
                        [ \attrs ->
                            [ "🎉" |> Layout.text [ Html.Attributes.style "font-size" "40px" ]
                            , "You win"
                                |> Layout.text
                                    [ Html.Attributes.style "font-size" "20px"
                                    ]
                            , "Score" |> Layout.text []
                            , String.fromInt args.score |> Layout.text []
                            ]
                                |> View.overlay
                                    ([ Html.Events.onClick CloseOverlay
                                     ]
                                        ++ attrs
                                    )
                        ]

                    Just Game.GameLost ->
                        [ \attrs ->
                            [ "☠️" |> Layout.text [ Html.Attributes.style "font-size" "40px" ]
                            , "You Lost "
                                |> Layout.text
                                    [ Html.Attributes.style "font-size" "20px"
                                    ]
                            ]
                                |> View.overlay
                                    ([ Html.Events.onClick CloseOverlay
                                     ]
                                        ++ attrs
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
        OpenOverlay overlay ->
            { model | overlay = Just overlay }


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

        BoughtPack pack ->
            model.game
                |> Game.buyPack pack
                |> Maybe.map (\gen -> Random.step gen model.seed)
                |> Maybe.map
                    (\( game, seed ) ->
                        ( { model
                            | game = game
                            , seed = seed
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
