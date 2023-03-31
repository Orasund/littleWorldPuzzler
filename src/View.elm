module View exposing (..)

import Card exposing (Card, NeighborExpression)
import Config
import Deck exposing (Deck)
import Game.Area
import Game.Card
import Game.Entity exposing (Entity)
import Html exposing (Attribute, Html)
import Html.Attributes
import Layout
import Round exposing (CardId)


button : Maybe msg -> String -> Html msg
button onPress label =
    Html.text label
        |> Layout.button
            [ Html.Attributes.style "border-radius" "16px"
            , Html.Attributes.style "border" "1px solid rgba(0,0,0,0.2)"
            ]
            { label = label
            , onPress = onPress
            }


viewCard : List (Attribute msg) -> Card -> Html msg
viewCard attrs card =
    [ card
        |> Card.emoji
        |> Layout.text [ Html.Attributes.style "padding" "4px" ]
    , card
        |> Card.emoji
        |> Layout.text
            ([ Layout.fill
             , Html.Attributes.style "font-size" "50px"
             ]
                ++ Layout.centered
            )
    ]
        |> Game.Card.default
            ([ Html.Attributes.style "height" (String.fromFloat Config.cardHeight ++ "px")
             , Html.Attributes.style "width" (String.fromFloat Config.cardWidth ++ "px")
             , Html.Attributes.style "opacity" "1"
             ]
                ++ attrs
            )


viewPack : Deck -> Html msg
viewPack pack =
    [ (\attrs ->
        viewCardBack pack
            (attrs ++ [ Html.Attributes.style "width" (String.fromFloat Config.cardWidth ++ "px") ])
      )
        |> Game.Entity.new
        |> List.repeat (List.length (Deck.cards pack))
        |> List.indexedMap
            (\i ->
                Game.Entity.move ( 0, toFloat (List.length (Deck.cards pack) * 3) - toFloat i * 3 )
            )
        |> Game.Entity.pileAbove
            (Layout.el
                [ Html.Attributes.style "width" (String.fromFloat Config.cardWidth ++ "px")
                , Html.Attributes.style "height"
                    (String.fromFloat
                        (Config.cardHeight
                            + toFloat
                                (List.length (Deck.cards pack)
                                    * 3
                                )
                        )
                        ++ "px"
                    )
                ]
                Layout.none
            )
        |> Game.Entity.toHtml []
    , Deck.cards pack
        |> List.map Card.emoji
        |> String.concat
        |> Layout.text
            [ Html.Attributes.style "width" (String.fromFloat Config.cardWidth ++ "px")
            ]
    ]
        |> Layout.column [ Layout.gap 8 ]


viewEmptyCard : List (Attribute msg) -> String -> Html msg
viewEmptyCard attrs title =
    Game.Card.empty
        ([ Html.Attributes.style "height" (String.fromFloat Config.cardHeight ++ "px")
         , Html.Attributes.style "width" (String.fromFloat Config.cardWidth ++ "px")
         ]
            ++ attrs
        )
        title


viewCardBack : Deck -> List (Attribute msg) -> Html msg
viewCardBack pack attrs =
    let
        backgroundImage =
            case pack of
                Deck.IntroFire ->
                    "assets/seedBack.svg"

                Deck.IntroTree ->
                    "assets/leaveBack.svg"

                Deck.IntroVolcano ->
                    "assets/volcanoBack.svg"

                Deck.IntroButterfly ->
                    "assets/fireBack.svg"

                Deck.IntroIce ->
                    "assets/iceBack.svg"

                _ ->
                    "assets/defaultBack.svg"

        color =
            Deck.color pack
    in
    Layout.none
        |> Game.Card.back
            (Game.Card.backgroundImage backgroundImage
                ++ [ Html.Attributes.style "height" (String.fromFloat Config.cardHeight ++ "px")
                   , Html.Attributes.style "background-size" "50%"
                   , Html.Attributes.style "background-color" color
                   , Html.Attributes.style "opacity" "1"
                   ]
                ++ attrs
            )


neighborExp : NeighborExpression -> String
neighborExp exp0 =
    let
        rec exp =
            case exp of
                Card.Either exps ->
                    "either "
                        ++ (exps
                                |> List.map rec
                                |> String.join " or "
                           )

                Card.NextTo card ->
                    "next to " ++ Card.emoji card

                Card.NextToTwo card ->
                    "next to "
                        ++ Card.emoji card
                        ++ Card.emoji card

                Card.Not e ->
                    "not " ++ rec e

                Card.Anything ->
                    "placed"

                Card.Something ->
                    "next to some non empty cell"
    in
    case exp0 of
        Card.Anything ->
            " once placed"

        _ ->
            "if " ++ rec exp0


description : List (Attribute msg) -> Card -> Html msg
description attrs card =
    [ "Rules for "
        ++ Card.emoji card
        |> Layout.text
            [ Html.Attributes.style "font-weight" "bold"
            , Html.Attributes.style "font-size" "20px"
            ]
    , Card.produces card
        |> (\( newCard, exp ) ->
                "Produces "
                    ++ Card.emoji newCard
                    ++ " "
                    ++ neighborExp exp
                    ++ "."
           )
        |> Layout.text []
    , Card.transform card
        |> (\( maybeCard, exp ) ->
                maybeCard
                    |> Maybe.map
                        (\newCard ->
                            "Turns into " ++ Card.emoji newCard
                        )
                    |> Maybe.withDefault "Disappears"
                    |> (\string ->
                            string
                                ++ " "
                                ++ neighborExp exp
                                ++ "."
                       )
           )
        |> Layout.text []
    ]
        |> Layout.column (Layout.gap 8 :: attrs)


cell : { clicked : msg, neighbors : List Card } -> Maybe Card -> Html msg
cell args maybeCard =
    maybeCard
        |> Maybe.map Card.emoji
        |> Maybe.withDefault ""
        |> Layout.text
            [ Html.Attributes.style "transition" "transform 0.5s"
            , if maybeCard == Nothing then
                Html.Attributes.style "transform" "scale(0)"

              else
                Html.Attributes.style "transform" "scale(1)"
            ]
        |> Layout.button
            (Layout.centered
                ++ [ Html.Attributes.style "width" "80px"
                   , Html.Attributes.style "height" "80px"
                   , Html.Attributes.style "border-radius" "16px"
                   , Html.Attributes.style "font-size" "48px"
                   , Html.Attributes.style
                        "border"
                        "1px solid rgba(0,0,0,0.2)"
                   ]
            )
            { onPress =
                if maybeCard == Nothing then
                    args.clicked |> Just

                else
                    Nothing
            , label =
                maybeCard
                    |> Maybe.map Card.emoji
                    |> Maybe.withDefault " "
            }
        |> Layout.withStack []
            ([ maybeCard
                |> Maybe.map Card.produces
                |> Maybe.andThen
                    (\( to, exp ) ->
                        if Card.isValidNeighborhoods args.neighbors exp then
                            (\attrs ->
                                Card.emoji to
                                    |> Layout.text
                                        (Layout.centered
                                            ++ [ Html.Attributes.style "border-radius" "8px"
                                               , Html.Attributes.style "right" "-8px"
                                               , Html.Attributes.style "top" "-8px"
                                               , Html.Attributes.style "height" "30px"
                                               , Html.Attributes.style "width" "22px"
                                               , Html.Attributes.style "background-color" "white"
                                               , Html.Attributes.style "border" "1px solid rgba(0,0,0,0.2)"
                                               , Html.Attributes.style "font-size" "14px"
                                               ]
                                            ++ attrs
                                        )
                            )
                                |> Just

                        else
                            Nothing
                    )
             , if
                maybeCard
                    |> Maybe.map Card.produces
                    |> Maybe.map Tuple.second
                    |> Maybe.map (Card.isValidNeighborhoods args.neighbors)
                    |> Maybe.withDefault False
               then
                (\attrs ->
                    "➕"
                        |> Layout.text
                            (Layout.centered
                                ++ [ Html.Attributes.style "right" "10px"
                                   , Html.Attributes.style "top" "0px"
                                   , Html.Attributes.style "font-size" "10px"
                                   ]
                                ++ attrs
                            )
                )
                    |> Just

               else
                Nothing
             , maybeCard
                |> Maybe.map Card.transform
                |> Maybe.andThen
                    (\( to, exp ) ->
                        if Card.isValidNeighborhoods args.neighbors exp then
                            (\attrs ->
                                to
                                    |> Maybe.map Card.emoji
                                    |> Maybe.withDefault "☠️"
                                    |> Layout.text
                                        (Layout.centered
                                            ++ [ Html.Attributes.style "border-radius" "8px"
                                               , Html.Attributes.style "left" "26px"
                                               , Html.Attributes.style "bottom" "0"
                                               , Html.Attributes.style "height" "24px"
                                               , Html.Attributes.style "aspect-ratio" "1"
                                               , Html.Attributes.style "background-color" "white"
                                               , Html.Attributes.style "border" "1px solid rgba(0,0,0,0.2)"
                                               ]
                                            ++ attrs
                                        )
                            )
                                |> Just

                        else
                            Nothing
                    )
             ]
                |> List.filterMap identity
            )


deck : Deck -> List ( CardId, Card ) -> List (Entity ( String, List (Attribute msg) -> Html msg ))
deck pack cards =
    cards
        |> List.map
            (\( cardId, card ) ->
                ( Deck.asId cardId pack, viewCardBack pack )
                    |> Game.Entity.new
            )
        |> List.indexedMap
            (\i ->
                Game.Entity.move ( 0, -3 * toFloat i )
            )
        |> Game.Area.pileAbove ( 0, 0 )
            ( "deck_" ++ Deck.toString pack
            , \attrs ->
                "Deck"
                    |> viewEmptyCard []
                    |> Layout.withStack attrs
                        [ \a ->
                            cards
                                |> List.map Tuple.second
                                |> List.map Card.emoji
                                |> String.concat
                                |> Layout.text
                                    (a
                                        ++ [ Html.Attributes.style "right" (String.fromFloat Config.cardWidth ++ "px")
                                           , Html.Attributes.style "width" (String.fromFloat Config.cardWidth ++ "px")
                                           ]
                                    )
                        ]
            )


overlay : List (Attribute msg) -> List (Html msg) -> Html msg
overlay attrs content =
    content
        |> Layout.column
            ([ Html.Attributes.style "background-color" "white"
             , Html.Attributes.style "border" "solid 1px rgba(0,0,0,0.2)"
             , Html.Attributes.style "padding" "32px"
             , Html.Attributes.style "width" "300px"
             , Html.Attributes.style "height" "300px"
             , Html.Attributes.style "border-radius" "8px"
             , Layout.gap 16
             ]
                ++ Layout.centered
            )
        |> Layout.el
            ([ Html.Attributes.style "backdrop-filter" "blur(4px)"
             , Html.Attributes.style "width" "100%"
             , Html.Attributes.style "height" "100%"
             , Html.Attributes.style "z-index" "1000"
             ]
                ++ attrs
                ++ Layout.centered
            )
