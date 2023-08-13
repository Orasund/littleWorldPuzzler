module View.CardSelector exposing (..)

import Config
import Data.Card as CellType exposing (CellType)
import Data.Deck exposing (Selected)
import Html exposing (Attribute, Html)
import Html.Attributes
import Layout
import View.Button
import View.Color as Color


toHtml : { onSelect : Selected -> Maybe msg } -> List ( Selected, CellType ) -> Html msg
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
