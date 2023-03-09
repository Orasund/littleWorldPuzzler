module Main exposing (..)

import Browser exposing (Document)
import Card exposing (Card)
import Config
import Dict
import Game exposing (Game)
import Html
import Html.Attributes
import Layout
import Random exposing (Seed)
import View


type alias Model =
    { game : Game
    , seed : Seed
    }


type Msg
    = ClickedAt ( Int, Int )
    | BoughtCard Card
    | Restart Seed


init : () -> ( Model, Cmd Msg )
init () =
    ( { game = Game.init
      , seed = Random.initialSeed 42
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
                    [ Layout.spaceBetween
                    , Html.Attributes.style "width" "100%"
                    ]
          , List.range 0 (Config.worldSize - 1)
                |> List.map
                    (\y ->
                        List.range 0 (Config.worldSize - 1)
                            |> List.map
                                (\x ->
                                    model.game.world
                                        |> Dict.get ( x, y )
                                        |> (\maybeCard ->
                                                maybeCard
                                                    |> Maybe.map Card.emoji
                                                    |> Maybe.withDefault ""
                                                    |> Html.text
                                                    |> Layout.buttonEl
                                                        { onPress =
                                                            if maybeCard == Nothing then
                                                                ClickedAt ( x, y ) |> Just

                                                            else
                                                                Nothing
                                                        , label =
                                                            maybeCard
                                                                |> Maybe.map Card.emoji
                                                                |> Maybe.withDefault " "
                                                        }
                                                        (Layout.centered
                                                            ++ [ Html.Attributes.style "width" "64px"
                                                               , Html.Attributes.style "height" "64px"
                                                               , Html.Attributes.style "border-radius" "16px"
                                                               , Html.Attributes.style "font-size" "48px"
                                                               , Html.Attributes.style
                                                                    "border"
                                                                    "1px solid rgba(0,0,0,0.2)"
                                                               ]
                                                        )
                                           )
                                )
                            |> Layout.row [ Layout.spacing 8 ]
                    )
                |> Layout.column [ Layout.spacing 8 ]
          , [ "Selected:"
                ++ (model.game.selected
                        |> Maybe.map Card.emoji
                        |> Maybe.withDefault ""
                   )
                |> Html.text
                |> Layout.el []
            , "Deck: "
                ++ (model.game.deck
                        |> List.map Card.emoji
                        |> String.concat
                   )
                |> Html.text
                |> Layout.el []
            ]
                |> Layout.row
                    [ Layout.spaceBetween
                    , Html.Attributes.style "width" "100%"
                    ]
          , [ "Buy Cards" |> Html.text |> Layout.el []
            , Card.asList
                |> List.map
                    (\card ->
                        Card.emoji card
                            ++ " for "
                            ++ String.fromInt (Card.price card)
                            |> View.button (Just (BoughtCard card))
                    )
                |> Layout.row [ Layout.spacing 8 ]
            ]
                |> Layout.column
                    (Layout.spacing 8
                        :: Layout.centered
                    )
          ]
            |> Layout.column
                ([ Layout.spacing 32
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClickedAt pos ->
            ( model.seed
                |> Random.step (Game.placeCard pos model.game)
                |> (\( game, seed ) ->
                        { model
                            | game = game
                            , seed = seed
                        }
                   )
            , Cmd.none
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
