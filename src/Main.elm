module Main exposing (..)

import Browser exposing (Document)
import Card exposing (Card)
import Config
import Dict
import Game exposing (Effect(..), Game)
import Game.Card
import Html
import Html.Attributes
import Layout
import Random exposing (Seed)
import View


type alias Model =
    { game : Game
    , seed : Seed
    , viewShop : Bool
    }


type Msg
    = ClickedAt ( Int, Int )
    | SwapCards
    | BoughtCard Card
    | Restart Seed
    | CloseShop


init : () -> ( Model, Cmd Msg )
init () =
    ( { game = Game.init
      , seed = Random.initialSeed 42
      , viewShop = False
      }
    , Random.generate Restart Random.independentSeed
    )


view : Model -> Document Msg
view model =
    { title = "Little World Puzzler"
    , body =
        [ [ [ "Points: "
                ++ String.fromInt model.game.points
                |> Html.text
                |> Layout.el []
            , View.button (Just (Restart model.seed)) "Restart"
            ]
                |> Layout.row
                    [ Layout.contentWithSpaceBetween
                    , Html.Attributes.style "width" "100%"
                    ]
          , (if model.viewShop then
                [ "Buy Cards" |> Html.text |> Layout.el []
                , Card.asList
                    |> List.map
                        (\card ->
                            [ View.viewCard card
                            , "Buy for "
                                ++ String.fromInt (Card.price card)
                                |> View.button (Just (BoughtCard card))
                            ]
                                |> Layout.column (Layout.centered ++ [ Layout.gap 8 ])
                        )
                    |> Layout.row [ Layout.gap 8 ]
                , View.button
                    (if model.game.deck /= [] then
                        Just CloseShop

                     else
                        Nothing
                    )
                    "Close"
                ]

             else
                List.range 0 (Config.worldSize - 1)
                    |> List.map
                        (\y ->
                            List.range 0 (Config.worldSize - 1)
                                |> List.map
                                    (\x ->
                                        model.game.world
                                            |> Dict.get ( x, y )
                                            |> (\maybeCard ->
                                                    View.cell
                                                        { clicked = ClickedAt ( x, y )
                                                        , neighbors =
                                                            Game.neighborsOf ( x, y )
                                                                |> List.filterMap
                                                                    (\p -> Dict.get p model.game.world)
                                                        }
                                                        maybeCard
                                               )
                                    )
                                |> Layout.row [ Layout.gap 8 ]
                        )
            )
                |> Layout.column
                    ([ Layout.fill, Layout.gap 8 ]
                        ++ Layout.centered
                    )
          , [ [ model.game.backpack
                    |> Maybe.map View.viewCard
                    |> Maybe.withDefault
                        ("Backpack"
                            |> View.viewEmptyCard
                        )
                    |> Layout.el (Layout.asButton { onPress = Just SwapCards, label = "swap cards" })
              , "Click to swap" |> Layout.text []
              ]
                |> Layout.column []
            , model.game.selected
                |> Maybe.map View.viewCard
                |> Maybe.withDefault Layout.none
            , model.game.deck
                |> View.deck
            ]
                |> Layout.row
                    [ Layout.contentWithSpaceBetween
                    , Html.Attributes.style "width" "100%"
                    ]
          ]
            |> Layout.column
                ([ Layout.gap 32
                 , Html.Attributes.style "width" "400px"
                 , Html.Attributes.style "height" "600px"
                 , Html.Attributes.style "border" "1px solid rgba(0,0,0,0.2)"
                 , Html.Attributes.style "border-radius" "16px"
                 , Html.Attributes.style "padding" "32px"
                 ]
                    ++ Layout.centered
                )
            |> Layout.el
                (Html.Attributes.style "height" "100%"
                    :: Layout.centered
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

.cardback {
    background-color: #e5e5f7;
background-image:  linear-gradient(135deg, #444cf7 25%, transparent 25%), linear-gradient(225deg, #444cf7 25%, transparent 25%), linear-gradient(45deg, #444cf7 25%, transparent 25%), linear-gradient(315deg, #444cf7 25%, #e5e5f7 25%);
background-position:  10px 0, 10px 0, 0 0, 0 0;
background-size: 20px 20px;
background-repeat: repeat;
}
""" ]
        ]
    }


applyEffect : Effect -> Model -> Model
applyEffect effect model =
    case effect of
        OpenShop ->
            { model | viewShop = True }


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

        BoughtCard card ->
            ( model.game
                |> Game.buyCard card
                |> (\it -> { model | game = it })
            , Cmd.none
            )

        Restart initialSeed ->
            Random.step (Game.drawCard Game.init) initialSeed
                |> (\( game, seed ) ->
                        ( { model
                            | game = game
                            , seed = seed
                          }
                        , Cmd.none
                        )
                   )

        CloseShop ->
            Random.step (Game.drawCard model.game) model.seed
                |> (\( game, seed ) ->
                        ( { model
                            | game = game
                            , seed = seed
                            , viewShop = False
                          }
                        , Cmd.none
                        )
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
