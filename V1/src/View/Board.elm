module View.Board exposing (toHtml, toHtmlWithoutInteraction)

import Data.Card as CellType exposing (Card)
import Data.Deck as Deck exposing (Deck, Selected(..))
import Element exposing (Element)
import Framework.Grid as Grid
import Grid.Bordered as Grid exposing (Grid)
import Html exposing (Attribute, Html)
import Html.Attributes
import Layout
import View.CardSelector
import View.Color


viewCell : List (Html.Attribute msg) -> { position : ( Int, Int ), onPress : Maybe (( Int, Int ) -> msg) } -> Maybe Card -> Html msg
viewCell attrs args maybeCellType =
    let
        size =
            80
    in
    maybeCellType
        |> Maybe.map CellType.toString
        |> Maybe.withDefault ""
        |> Layout.text
            [ Html.Attributes.style "z-index" "1"
            , Html.Attributes.style "font-size" "60px"
            ]
        |> Layout.el
            ([ Html.Attributes.style "border" ("1px solid " ++ View.Color.borderColor)
             , Html.Attributes.style "height" (String.fromFloat size ++ "px")
             , Html.Attributes.style "width" (String.fromFloat size ++ "px")
             ]
                ++ Layout.centered
                ++ (case args.onPress of
                        Just msg ->
                            Layout.asButton
                                { label = ""
                                , onPress = msg args.position |> Just
                                }

                        Nothing ->
                            []
                   )
                ++ attrs
            )


toHtmlWithoutInteraction : { scale : Float } -> Grid Card -> Element msg
toHtmlWithoutInteraction args grid =
    grid
        |> view []
            { scale = args.scale
            , onPress = Nothing
            , onPlace = \_ _ -> Nothing
            , positionSelected = Nothing
            , deck = Nothing
            }
        |> Element.html


toHtml :
    List (Attribute msg)
    ->
        { scale : Float
        , onPress : Maybe (( Int, Int ) -> msg)
        , onPlace : ( Int, Int ) -> Selected -> msg
        , positionSelected : Maybe ( Int, Int )
        , deck : Deck
        }
    -> Grid Card
    -> Html msg
toHtml attrs args =
    view attrs
        { scale = args.scale
        , onPress = args.onPress
        , onPlace = \a b -> args.onPlace a b |> Just
        , positionSelected = args.positionSelected
        , deck = Just args.deck
        }


view :
    List (Attribute msg)
    ->
        { scale : Float
        , onPress : Maybe (( Int, Int ) -> msg)
        , onPlace : ( Int, Int ) -> Selected -> Maybe msg
        , positionSelected : Maybe ( Int, Int )
        , deck : Maybe Deck
        }
    -> Grid Card
    -> Html msg
view attrs args grid =
    Layout.column attrs <|
        (grid
            |> Grid.foldr
                (\( x, y ) maybeCellType ( workingRow, list ) ->
                    let
                        newRow : List (Html msg)
                        newRow =
                            (case args.positionSelected of
                                Just a ->
                                    if a == ( x, y ) then
                                        [ viewCell []
                                            { position = ( x, y )
                                            , onPress = Nothing
                                            }
                                            maybeCellType
                                        , [ args.deck |> Maybe.map Deck.first |> Maybe.map (Tuple.pair First)
                                          , args.deck |> Maybe.andThen Deck.second |> Maybe.map (Tuple.pair Second)
                                          ]
                                            |> List.filterMap identity
                                            |> View.CardSelector.toHtml { onSelect = args.onPlace a }
                                            |> Layout.el
                                                ([ Html.Attributes.style "height" "100%"
                                                 , Html.Attributes.style "z-index" "10"
                                                 , Html.Attributes.style "position" "absolute"
                                                 , Html.Attributes.style "top" "0"
                                                 , Html.Attributes.style "left" "-12.5%"
                                                 ]
                                                    ++ Layout.centered
                                                )
                                        ]
                                            |> Html.div [ Html.Attributes.style "position" "relative" ]

                                    else
                                        viewCell []
                                            { position = ( x, y )
                                            , onPress = args.onPress
                                            }
                                            maybeCellType

                                Nothing ->
                                    viewCell []
                                        { position = ( x, y )
                                        , onPress = args.onPress
                                        }
                                        maybeCellType
                            )
                                :: workingRow
                    in
                    if y == 0 then
                        ( [], newRow :: list )

                    else
                        ( newRow, list )
                )
                ( [], [] )
            |> Tuple.second
            |> List.map
                (Layout.row
                    []
                )
        )
