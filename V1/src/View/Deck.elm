module View.Deck exposing (view)

import Config
import Data.Card as CellType exposing (Card(..))
import Data.Deck as Deck exposing (Deck, Selected(..))
import Html exposing (Html)
import Html.Attributes
import Layout
import View
import View.Card


view : { viewCard : Card -> msg } -> Deck -> Html msg
view args deck =
    [ [ "📤" |> Layout.text [ Html.Attributes.style "font-size" "30px" ]
      , [ deck
            |> Deck.remaining
            |> List.tail
            |> Maybe.withDefault []
            |> List.map
                (\card ->
                    card
                        |> CellType.toString
                        |> Layout.text
                            (Layout.asButton
                                { label = "Show Details"
                                , onPress = args.viewCard card |> Just
                                }
                            )
                )
            |> Layout.row
                [ Layout.gap Config.smallSpace
                ]
        , deck
            |> Deck.played
            |> List.map CellType.toString
            |> List.map (Layout.text [])
            |> Layout.row
                [ Layout.gap Config.smallSpace
                , Layout.contentAtEnd
                ]
        ]
            |> Layout.row [ Layout.fill, Layout.contentWithSpaceBetween ]
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
    , deck |> Deck.second
    ]
        |> List.filterMap identity
        |> List.map
            (\cellType ->
                cellType
                    |> View.Card.asSmallCard
                        (Layout.asButton { label = "Show Details", onPress = args.viewCard cellType |> Just })
            )
        |> Layout.row [ Layout.gap Config.smallSpace ]
