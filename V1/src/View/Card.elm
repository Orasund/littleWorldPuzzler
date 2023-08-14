module View.Card exposing (..)

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
    [ CellType.name cellType
        |> Layout.text []
    , CellType.toString cellType
        |> Layout.text (Layout.centered ++ [ Html.Attributes.style "font-size" "4rem" ])
    , asRules
        ([ Html.Attributes.style "font-size" "1.2rem"
         , Layout.gap Config.smallSpace
         ]
            ++ Layout.centered
        )
        cellType
    ]
        |> Layout.column
            [ Layout.contentWithSpaceBetween
            , Html.Attributes.style "height" "100%"
            , Html.Attributes.style "width" "100%"
            ]
        |> View.card
            ([ Html.Attributes.style "background-color" View.Color.background
             , Html.Attributes.style "border" ("2px solid" ++ View.Color.background)
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
    [ CellType.name cellType
        |> Layout.text []
    , CellType.toString cellType
        |> Layout.text (Layout.centered ++ [ Html.Attributes.style "font-size" "3rem" ])
    , asRules
        ([ Html.Attributes.style "font-size" "0.8rem"
         , Layout.gap Config.smallSpace
         , Html.Attributes.style "width" "100%"
         ]
            ++ Layout.centered
        )
        cellType
    ]
        |> Layout.column
            [ Layout.contentWithSpaceBetween
            , Html.Attributes.style "height" "100%"
            , Html.Attributes.style "width" "100%"
            ]
        |> View.card
            ([ Html.Attributes.style "background-color" View.Color.background
             , Html.Attributes.style "border" ("2px solid " ++ View.Color.borderColor)
             , Html.Attributes.style "width" (String.fromFloat width ++ "px")
             , Html.Attributes.style "height" (String.fromFloat (width * 3 / 2) ++ "px")
             ]
                ++ attrs
            )


asRules : List (Attribute msg) -> Card -> Html msg
asRules attrs cellType =
    Rule.rules cellType
        |> List.map
            (\{ to, neighbors } ->
                [ Neighborhood.toString neighbors
                    |> Layout.text
                        [ Layout.fill
                        , Layout.contentAtEnd
                        ]
                , Layout.text [] "➡"
                , Maybe.map CellType.toString to
                    |> Maybe.withDefault " "
                    |> Layout.text [ Layout.fill ]
                ]
                    |> Layout.row
                        [ Layout.noWrap
                        , Html.Attributes.style "width" "100%"
                        ]
            )
        |> Layout.column (Html.Attributes.style "width" "100%" :: attrs)
