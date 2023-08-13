module View.CardSelector exposing (..)

import Config
import Data.Card as CellType exposing (Card)
import Data.Deck exposing (Selected)
import Html exposing (Html)
import Layout
import View.Button


toHtml : { onSelect : Selected -> Maybe msg } -> List ( Selected, Card ) -> Html msg
toHtml args list =
    list
        |> List.map
            (\( selected, cellType ) ->
                cellType
                    |> CellType.toString
                    |> Html.text
                    |> View.Button.iconButton []
                        { onPress = args.onSelect selected
                        , label = "Place " ++ CellType.name cellType
                        , size = 48
                        }
            )
        |> Layout.row [ Layout.noWrap, Layout.gap Config.smallSpace ]
