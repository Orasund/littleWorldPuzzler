module View.Tab exposing (..)

import Card exposing (Card)
import Dict
import Html exposing (Html)
import Html.Attributes
import Layout
import Round exposing (Round)
import Set
import View


toHtml : { round : Round, onSelect : Card -> msg } -> Maybe Card -> Html msg
toHtml args selectedInfoTab =
    [ [ args.round.world
            |> Dict.values
      , args.round
            |> Round.getSelected
            |> Maybe.map Tuple.second
            |> Maybe.map List.singleton
            |> Maybe.withDefault []
      , args.round
            |> Round.getBackpack
            |> Maybe.map Tuple.second
            |> Maybe.map List.singleton
            |> Maybe.withDefault []
      , args.round
            |> Round.getDeck
            |> List.map Tuple.second
      ]
        |> List.concat
        |> List.sortBy Card.emoji
        |> List.foldl
            (\card list ->
                case list of
                    head :: _ ->
                        if head == card then
                            list

                        else
                            card :: list

                    [] ->
                        [ card ]
            )
            []
        |> List.map
            (\card ->
                card
                    |> Card.emoji
                    |> Layout.text
                        ([ Html.Attributes.style "padding" "4px"
                         , Html.Attributes.style "border" "1px dashed rgba(0,0,0,0.2)"
                         , Html.Attributes.style "border-radius" "8px 8px 0 0"
                         , Html.Attributes.style "border-bottom-width" "0"
                         ]
                            ++ Layout.asButton { label = "Select", onPress = Just (args.onSelect card) }
                        )
            )
        |> Layout.row [ Layout.gap 4 ]
    , selectedInfoTab
        |> Maybe.map
            (View.description
                [ Html.Attributes.style "border" "1px dashed rgba(0,0,0,0.2)"
                , Html.Attributes.style "padding" "8px"
                ]
            )
        |> Maybe.withDefault Layout.none
    ]
        |> Layout.column []
