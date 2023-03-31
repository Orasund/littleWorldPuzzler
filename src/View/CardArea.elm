module View.CardArea exposing (..)

import Config
import Deck
import Dict
import Game.Area
import Game.Entity
import Html exposing (Attribute, Html)
import Html.Attributes
import Layout
import Round exposing (CardId, Round)
import View


toHtml : { onSwapCards : msg, lastSelectedCard : Maybe CardId } -> List (Attribute msg) -> Round -> Html msg
toHtml args a round =
    let
        size =
            400
    in
    [ args.lastSelectedCard
        |> Maybe.andThen
            (\cardId ->
                round.cards
                    |> Dict.get cardId
                    |> Maybe.map
                        (\card ->
                            (\attrs ->
                                View.viewCard
                                    (attrs
                                        ++ [ Html.Attributes.style "opacity" "0"
                                           , Html.Attributes.style "transition" "transform 1s, opacity 1s"
                                           ]
                                    )
                                    card
                            )
                                |> Tuple.pair (Deck.asId cardId round.pack)
                                |> Game.Entity.new
                                |> Game.Entity.move ( 0, -200 )
                        )
            )
    , ( Deck.asId round.nextCardId round.pack
      , \attrs ->
            View.viewCardBack round.pack
                (attrs
                    ++ [ Html.Attributes.style "opacity" "0"
                       , Html.Attributes.style "transition" "transform 1s, opacity 1s"
                       ]
                )
      )
        |> Game.Entity.new
        |> Game.Entity.move ( size / 2 - Config.cardWidth / 2, -50 )
        |> Just
    , round
        |> Round.getBackpack
        |> Maybe.map
            (\( cardId, card ) ->
                (\attrs -> View.viewCard attrs card)
                    |> Tuple.pair (Deck.asId cardId round.pack)
                    |> Game.Entity.new
                    |> Game.Entity.rotate (-pi / 8)
                    |> Game.Entity.move ( -10, 0 )
            )
    , round
        |> Round.getSelected
        |> Maybe.map
            (\( cardId, card ) ->
                (\attrs -> View.viewCard attrs card)
                    |> Tuple.pair (Deck.asId cardId round.pack)
                    |> Game.Entity.new
                    |> Game.Entity.mapZIndex ((+) 1)
            )
    , if round.backpack /= Nothing then
        (\attrs ->
            "Click to swap"
                |> Layout.text
                    (Html.Attributes.style "width" "64px" :: attrs)
        )
            |> Tuple.pair "Click to swap"
            |> Game.Entity.new
            |> Game.Entity.rotate (-pi / 8)
            |> Game.Entity.move ( -70, -20 )
            |> Just

      else
        Nothing
    ]
        |> List.filterMap identity
        |> (++)
            (round
                |> Round.getDeck
                |> View.deck round.pack
                |> List.map (Game.Entity.move ( size / 2 - Config.cardWidth / 2, 0 ))
            )
        |> List.map (Game.Entity.move ( size / 2 - Config.cardWidth / 2, 0 ))
        |> Game.Area.toHtml
            ([ Layout.contentWithSpaceBetween
             , Html.Attributes.style "width" (String.fromFloat size ++ "px")
             , Html.Attributes.style "height" (String.fromFloat Config.cardHeight ++ "px")
             , Layout.alignAtEnd
             ]
                ++ Layout.asButton
                    { onPress = Just args.onSwapCards
                    , label = "Swap Cards"
                    }
                ++ a
            )
