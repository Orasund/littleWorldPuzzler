module View exposing (..)

import Card exposing (Card, NeighborExpression)
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
    [ (\attrs ->
        viewCardBack pack
            (attrs ++ [ Html.Attributes.style "width" (String.fromFloat Config.cardWidth ++ "px") ])
      )
        |> Game.Entity.new
        |> List.repeat (List.length (Pack.cards pack))
        |> List.indexedMap
            (\i ->
                Game.Entity.move ( 0, toFloat (List.length (Pack.cards pack) * 3) - toFloat i * 3 )
            )
        |> Game.Entity.pileAbove
            (Layout.el
                [ Html.Attributes.style "width" (String.fromFloat Config.cardWidth ++ "px")
                , Html.Attributes.style "height"
                    (String.fromFloat
                        (Config.cardHeight
                            + toFloat
                                (List.length (Pack.cards pack)
                                    * 3
                                )
                        )
                        ++ "px"
                    )
                ]
                Layout.none
            )
        |> Game.Entity.toHtml []
    , Pack.cards pack
        |> List.map Card.emoji
        |> String.concat
        |> Layout.text
            [ Html.Attributes.style "width" (String.fromFloat Config.cardWidth ++ "px")
            ]
    ]
        |> Layout.column [ Layout.gap 8 ]


viewEmptyCard : String -> Html msg
viewEmptyCard =
    Game.Card.empty
        [ Html.Attributes.style "height" (String.fromFloat Config.cardHeight ++ "px")
        , Html.Attributes.style "width" (String.fromFloat Config.cardWidth ++ "px")
        ]


viewCardBack : Pack -> List (Attribute msg) -> Html msg
viewCardBack pack attrs =
    let
        ( backgroundImage, color ) =
            case pack of
                Pack.IntroFire ->
                    ( "assets/fireBack.svg", "#F7B1AB" )

                Pack.IntroTree ->
                    ( "assets/leaveBack.svg", "#DCEDB9" )

                Pack.IntroVolcano ->
                    ( "assets/volcanoBack.svg", "#FF4B3E" )

                _ ->
                    ( "assets/seedBack.svg", "#DCEDB9" )
    in
    Layout.none
        |> Game.Card.back
            (Game.Card.backgroundImage backgroundImage
                ++ [ Html.Attributes.style "height" (String.fromFloat Config.cardHeight ++ "px")
                   , Html.Attributes.style "background-size" "50%"
                   , Html.Attributes.style "background-color" color
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
        |> Html.text
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
                            )
                                |> Just

                        else
                            Nothing
                    )
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
                                               , Html.Attributes.style "left" "0px"
                                               , Html.Attributes.style "buttom" "-8px"
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


deck : Pack -> List Card -> Html msg
deck pack cards =
    viewCardBack pack
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


overlay : List (Attribute msg) -> List (Html msg) -> Html msg
overlay attrs content =
    content
        |> Layout.column
            ([ Html.Attributes.style "background-color" "white"
             , Html.Attributes.style "border" "solid 1px rgba(0,0,0,0.2)"
             , Html.Attributes.style "padding" "32px"
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
