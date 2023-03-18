module Main exposing (..)

import Browser exposing (Document)
import Config
import Dict
import Game exposing (Effect(..), Game)
import Html
import Html.Attributes
import Layout
import Pack exposing (Pack)
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
    | BoughtPack Pack
    | Restart Seed


init : () -> ( Model, Cmd Msg )
init () =
    ( { game = Game.init
      , seed = Random.initialSeed 42
      , viewShop = True
      }
    , Random.generate Restart Random.independentSeed
    )


view : Model -> Document Msg
view model =
    { title = "Little World Puzzler"
    , body =
        [ [ [ "Points: "
                ++ String.fromInt model.game.points
                |> Layout.text []
            , "Turns left:"
                ++ String.fromInt model.game.turns
                |> Layout.text []
            , View.button (Just (Restart model.seed)) "Restart"
            ]
                |> Layout.row
                    [ Layout.contentWithSpaceBetween
                    , Html.Attributes.style "width" "100%"
                    ]
          , (if model.viewShop then
                [ "Choose a Pack" |> Layout.text []
                , Pack.asList
                    |> List.map
                        (\pack ->
                            [ pack |> View.viewPack
                            , "Play for "
                                ++ String.fromInt (Pack.price pack)
                                |> View.button (Just (BoughtPack pack))
                            ]
                                |> Layout.column (Layout.centered ++ [ Layout.gap 8 ])
                        )
                    |> Layout.row [ Layout.gap 8 ]
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
          , [ [ "Click to swap" |> Layout.text []
              , model.game.backpack
                    |> Maybe.map (View.viewCard [])
                    |> Maybe.withDefault
                        ("Backpack"
                            |> View.viewEmptyCard
                        )
                    |> Layout.el (Layout.asButton { onPress = Just SwapCards, label = "swap cards" })
              ]
                |> Layout.column [ Html.Attributes.style "width" (String.fromFloat Config.cardWidth ++ "px") ]
            , model.game.selected
                |> Maybe.map
                    (\card ->
                        [ View.description
                            [ Html.Attributes.style "bottom" "-100px"
                            , Html.Attributes.style "left" (String.fromFloat (Config.cardWidth * 1.5 + 5) ++ "px")
                            , Html.Attributes.style "width" "200px"
                            , Html.Attributes.style "border" "1px dashed rgba(0,0,0,0.2)"
                            , Html.Attributes.style "padding" "8px"
                            ]
                            card
                        , View.viewCard [] card
                        ]
                            |> Layout.column
                                [ Layout.alignAtCenter
                                , Layout.gap 8
                                ]
                    )
                |> Maybe.withDefault Layout.none
            , model.game.deck
                |> View.deck
            ]
                |> Layout.row
                    [ Layout.contentWithSpaceBetween
                    , Html.Attributes.style "width" "100%"
                    , Layout.alignAtEnd
                    ]
          ]
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

        BoughtPack pack ->
            model.game
                |> Game.buyPack pack
                |> Maybe.map Game.drawCard
                |> Maybe.map (\gen -> Random.step gen model.seed)
                |> Maybe.map
                    (\( game, seed ) ->
                        ( { model
                            | game = game
                            , seed = seed
                            , viewShop = False
                          }
                        , Cmd.none
                        )
                    )
                |> Maybe.withDefault ( model, Cmd.none )

        Restart initialSeed ->
            Random.step (Game.drawCard Game.init) initialSeed
                |> (\( game, seed ) ->
                        ( { model
                            | game = game
                            , seed = seed
                            , viewShop = True
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
