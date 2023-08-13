module View.CellType exposing (..)

import Automata.Neighborhood as Neighborhood
import Automata.Rule as Rule
import Config
import Data.Card as CellType exposing (Card)
import Html exposing (Attribute, Html)
import Html.Attributes
import Layout
import View
import View.Color


asBigCard : List (Attribute msg) -> Card -> Html msg
asBigCard attrs cellType =
    let
        width =
            200
    in
    [ cellType |> CellType.name |> Layout.text []
    , cellType |> CellType.toString |> Layout.text (Layout.centered ++ [ Html.Attributes.style "font-size" "4rem" ])
    , cellType
        |> asRules
            ([ Html.Attributes.style "font-size" "1.2rem"
             , Layout.gap Config.smallSpace
             ]
                ++ Layout.centered
            )
    ]
        |> Layout.column [ Layout.contentWithSpaceBetween, Html.Attributes.style "height" "100%" ]
        |> View.card
            ([ Html.Attributes.style "background-color" View.Color.cardBackground
             , Html.Attributes.style "width" (String.fromFloat width ++ "px")
             , Html.Attributes.style "height" (String.fromFloat (width * 3 / 2) ++ "px")
             ]
                ++ attrs
            )


asSmallCard : List (Attribute msg) -> Card -> Html msg
asSmallCard attrs cellType =
    let
        width =
            90
    in
    [ cellType |> CellType.name |> Layout.text []
    , cellType |> CellType.toString |> Layout.text (Layout.centered ++ [ Html.Attributes.style "font-size" "3rem" ])
    , cellType
        |> asRules
            ([ Html.Attributes.style "font-size" "0.8rem"
             , Layout.gap Config.smallSpace
             ]
                ++ Layout.centered
            )
    ]
        |> Layout.column [ Layout.contentWithSpaceBetween, Html.Attributes.style "height" "100%" ]
        |> View.card
            ([ Html.Attributes.style "background-color" View.Color.cardBackground
             , Html.Attributes.style "width" (String.fromFloat width ++ "px")
             , Html.Attributes.style "height" (String.fromFloat (width * 3 / 2) ++ "px")
             ]
                ++ attrs
            )


asRules : List (Attribute msg) -> Card -> Html msg
asRules attrs cellType =
    cellType
        |> Rule.rules
        |> List.map
            (\{ from, to, neighbors } ->
                (from |> Maybe.map CellType.toString |> Maybe.withDefault " ")
                    ++ "➕"
                    ++ Neighborhood.toString neighbors
                    ++ "➡"
                    ++ (to |> Maybe.map CellType.toString |> Maybe.withDefault " ")
                    |> Layout.text []
            )
        |> Layout.column attrs
