module View exposing (..)

import Card exposing (Card)
import Config
import Game.Card
import Game.Entity
import Html exposing (Attribute, Html)
import Html.Attributes
import Layout
import Pack exposing (Pack)


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
            (attrs
                ++ [ Html.Attributes.style "height" (String.fromFloat Config.cardHeight ++ "px")
                   , Html.Attributes.style "width" (String.fromFloat Config.cardWidth ++ "px")
                   ]
            )


viewPack : Pack -> Html msg
viewPack pack =
    Pack.cards pack
        |> List.indexedMap
            (\i card ->
                (\attrs -> viewCard attrs card)
                    |> Game.Entity.new
                    |> Game.Entity.move ( toFloat i * 16, 0 )
            )
        |> Game.Entity.pileAbove
            (Layout.el
                [ Html.Attributes.style "height" (String.fromFloat Config.cardHeight ++ "px")
                , Html.Attributes.style "width"
                    (String.fromFloat
                        (Config.cardWidth
                            + (Pack.cards pack
                                |> List.length
                                |> (+) -1
                                |> (*) 16
                                |> toFloat
                              )
                        )
                        ++ "px"
                    )
                ]
                Layout.none
            )
        |> Game.Entity.toHtml []


viewEmptyCard : String -> Html msg
viewEmptyCard =
    Game.Card.empty
        [ Html.Attributes.style "height" (String.fromFloat Config.cardHeight ++ "px")
        , Html.Attributes.style "width" (String.fromFloat Config.cardWidth ++ "px")
        ]


viewCardBack : List (Attribute msg) -> Html msg
viewCardBack attrs =
    Layout.none
        |> Game.Card.back
            ([ Html.Attributes.style "height" (String.fromFloat Config.cardHeight ++ "px")
             , Html.Attributes.class "cardback"
             ]
                ++ attrs
            )


cell : { clicked : msg, neighbors : List Card } -> Maybe Card -> Html msg
cell args maybeCard =
    maybeCard
        |> Maybe.map Card.emoji
        |> Maybe.withDefault ""
        |> Html.text
        |> Layout.button
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
            (maybeCard
                |> Maybe.map Card.produces
                |> Maybe.map
                    (\( to, fun ) ->
                        if fun args.neighbors then
                            [ \attrs ->
                                Card.emoji to
                                    |> Layout.text
                                        (Layout.centered
                                            ++ [ Html.Attributes.style "border-radius" "100%"
                                               , Html.Attributes.style "right" "-8px"
                                               , Html.Attributes.style "top" "-8px"
                                               , Html.Attributes.style "height" "24px"
                                               , Html.Attributes.style "aspect-ratio" "1"
                                               , Html.Attributes.style "background-color" "white"
                                               , Html.Attributes.style "border" "1px solid rgba(0,0,0,0.2)"
                                               ]
                                            ++ attrs
                                        )
                            ]

                        else
                            []
                    )
                |> Maybe.withDefault []
            )


deck : List Card -> Html msg
deck cards =
    viewCardBack
        |> Game.Entity.new
        |> List.repeat (List.length cards)
        |> List.indexedMap
            (\i ->
                Game.Entity.move ( 0, -3 * toFloat i )
            )
        |> Game.Entity.pileAbove
            ("Deck"
                |> viewEmptyCard
                |> Layout.withStack []
                    [ \attrs ->
                        cards
                            |> List.map Card.emoji
                            |> String.concat
                            |> Layout.text
                                (attrs
                                    ++ [ Html.Attributes.style "right" (String.fromFloat Config.cardWidth ++ "px")
                                       , Html.Attributes.style "width" (String.fromFloat Config.cardWidth ++ "px")
                                       ]
                                )
                    ]
            )
        |> Game.Entity.toHtml []
