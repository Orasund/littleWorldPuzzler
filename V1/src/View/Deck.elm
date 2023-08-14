module View.Deck exposing (view)

import Config
import Data.Card as CellType exposing (Card(..))
import Data.Deck as Deck exposing (Deck, Selected(..))
import Html exposing (Html)
import Html.Attributes
import Layout
import View
import View.Card
import View.Color


view : { viewCard : Card -> msg } -> Deck -> Html msg
view args deck =
    [ [ "📤" |> Layout.text [ Html.Attributes.style "font-size" "30px" ]
      , [ Deck.remaining deck
            |> List.tail
            |> Maybe.withDefault []
            |> List.map
                (\card ->
                    CellType.toString card
                        |> Layout.text
                            (Layout.asButton
                                { label = "Show Details"
                                , onPress = args.viewCard card |> Just
                                }
                            )
                )
            |> Layout.row
                [ Layout.gap Config.smallSpace
                , Html.Attributes.style "border-right" ("2px solid " ++ View.Color.borderColor)
                , Html.Attributes.style "padding-right" (String.fromInt Config.smallSpace ++ "px")
                ]
        , Deck.played deck
            |> List.map
                (\card ->
                    CellType.toString card
                        |> Layout.text
                            (Layout.asButton
                                { label = "Show Details"
                                , onPress = args.viewCard card |> Just
                                }
                            )
                )
            |> Layout.row
                [ Layout.gap Config.smallSpace
                , Layout.contentAtEnd
                , Html.Attributes.style "padding-left" (String.fromInt Config.smallSpace ++ "px")
                ]
        ]
            |> Layout.row
                [ Layout.fill
                , Layout.contentWithSpaceBetween
                , Layout.noWrap
                ]
      , "🗑" |> Layout.text [ Html.Attributes.style "font-size" "30px" ]
      ]
        |> Layout.row
            [ Html.Attributes.style "width" "100%"
            , Layout.gap Config.smallSpace
            ]
    , asCards args deck |> Layout.el Layout.centered
    ]
        |> Layout.column
            [ Layout.gap Config.space
            , Html.Attributes.style "width" "100%"
            ]


asCards : { viewCard : Card -> msg } -> Deck -> Html msg
asCards args deck =
    [ Deck.first deck |> Just
    , Deck.second deck
    ]
        |> List.filterMap identity
        |> List.map
            (\cellType ->
                View.Card.asSmallCard
                    (Layout.asButton { label = "Show Details", onPress = args.viewCard cellType |> Just })
                    cellType
            )
        |> Layout.row [ Layout.gap Config.smallSpace ]
