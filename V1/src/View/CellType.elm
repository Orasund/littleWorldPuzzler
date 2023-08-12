module View.CellType exposing (..)

import Automata.Neighborhood as Neighborhood
import Automata.Rule as Rule
import Config
import Data.CellType as CellType exposing (CellType)
import Html exposing (Html)
import Html.Attributes
import Layout
import View


asCard : CellType -> Html msg
asCard cellType =
    [ cellType |> CellType.name |> Layout.text []
    , cellType |> CellType.toString |> Layout.text (Layout.centered ++ [ Html.Attributes.style "font-size" "4rem" ])
    , cellType
        |> asRules
        |> Layout.column
            ([ Html.Attributes.style "font-size" "1.2rem"
             , Layout.gap Config.smallSpace
             ]
                ++ Layout.centered
            )
    ]
        |> Layout.column [ Layout.contentWithSpaceBetween, Html.Attributes.style "height" "100%" ]
        |> View.card
            [ Html.Attributes.style "aspect-ratio" "2/3"
            , Html.Attributes.style "color" "black"
            ]


asRules : CellType -> List (Html msg)
asRules =
    Rule.rules
        >> List.map
            (\{ from, to, neighbors } ->
                (from |> Maybe.map CellType.toString |> Maybe.withDefault " ")
                    ++ "➕"
                    ++ Neighborhood.toString neighbors
                    ++ "➡"
                    ++ (to |> Maybe.map CellType.toString |> Maybe.withDefault " ")
                    |> Layout.text []
            )
