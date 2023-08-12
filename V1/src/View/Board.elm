module View.Board exposing (toHtml, toHtmlWithoutInteraction)

import Data.CellType as CellType exposing (CellType)
import Data.Deck as Deck exposing (Deck, Selected(..))
import Element exposing (Attribute, Element)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Framework.Grid as Grid
import Grid.Bordered as Grid exposing (Grid)
import Html.Attributes
import Layout
import View.CardSelector
import View.Rule as RuleView


viewCell : List (Attribute msg) -> { scale : Float, position : ( Int, Int ), onPress : Maybe (( Int, Int ) -> msg) } -> Maybe CellType -> Element msg
viewCell attrs args maybeCellType =
    Element.el
        ([ Element.centerX
         , Border.width 1
         , Border.color <| Element.rgba255 219 219 219 1
         , Element.width <| Element.px <| floor <| args.scale * 100
         , Element.height <| Element.px <| floor <| args.scale * 100
         , Element.inFront <|
            Element.el
                [ Element.height <| Element.fill
                , Element.width <| Element.fill
                , Background.color <| Element.rgb255 242 242 242
                , Element.mouseOver [ Element.transparent True ]
                ]
            <|
                Element.el
                    [ Element.centerY
                    , Font.size <| floor <| args.scale * 90
                    , Element.centerX
                    , Font.center
                    ]
                <|
                    Element.text <|
                        (maybeCellType
                            |> Maybe.map CellType.toString
                            |> Maybe.withDefault ""
                        )
         ]
            ++ (case args.onPress of
                    Just msg ->
                        [ Events.onClick <| msg args.position ]

                    Nothing ->
                        []
               )
            ++ attrs
        )
    <|
        Element.column
            [ Element.centerY
            , Element.centerX
            , Font.center
            , Element.spacing <| floor <| args.scale * 10
            ]
        <|
            case maybeCellType of
                Just cellType ->
                    [ Element.el
                        [ Font.size <| floor <| args.scale * 50
                        , Font.center
                        , Element.centerX
                        ]
                      <|
                        Element.text <|
                            (cellType |> CellType.toString)
                    , Element.column
                        [ Font.size <| floor <| args.scale * 10
                        , Element.spacing <| floor <| args.scale * 5
                        , Element.centerX
                        ]
                        (RuleView.view cellType)
                    ]

                Nothing ->
                    []


toHtmlWithoutInteraction : { scale : Float } -> Grid CellType -> Element msg
toHtmlWithoutInteraction args =
    view
        { scale = args.scale
        , onPress = Nothing
        , onPlace = \_ _ -> Nothing
        , positionSelected = Nothing
        , deck = Nothing
        }


toHtml :
    { scale : Float
    , onPress : Maybe (( Int, Int ) -> msg)
    , onPlace : ( Int, Int ) -> Selected -> msg
    , positionSelected : Maybe ( Int, Int )
    , deck : Deck
    }
    -> Grid CellType
    -> Element msg
toHtml args =
    view
        { scale = args.scale
        , onPress = args.onPress
        , onPlace = \a b -> args.onPlace a b |> Just
        , positionSelected = args.positionSelected
        , deck = Just args.deck
        }


view :
    { scale : Float
    , onPress : Maybe (( Int, Int ) -> msg)
    , onPlace : ( Int, Int ) -> Selected -> Maybe msg
    , positionSelected : Maybe ( Int, Int )
    , deck : Maybe Deck
    }
    -> Grid CellType
    -> Element msg
view args grid =
    Element.column
        (Grid.compact
            ++ [ Element.centerX
               , Element.width <| Element.shrink
               , Element.height <| Element.px <| floor <| args.scale * 400
               ]
        )
    <|
        (grid
            |> Grid.foldr
                (\( x, y ) maybeCellType ( workingRow, list ) ->
                    let
                        newRow : List (Element msg)
                        newRow =
                            (case args.positionSelected of
                                Just a ->
                                    if a == ( x, y ) then
                                        viewCell
                                            [ [ args.deck |> Maybe.map Deck.first |> Maybe.map (Tuple.pair First)
                                              , args.deck |> Maybe.andThen Deck.second |> Maybe.map (Tuple.pair Second)
                                              ]
                                                |> List.filterMap identity
                                                |> View.CardSelector.toHtml { onSelect = args.onPlace a }
                                                |> Layout.el
                                                    ([ Html.Attributes.style "height" "100%"
                                                     , Html.Attributes.style "z-index" "1"
                                                     ]
                                                        ++ Layout.centered
                                                    )
                                                |> Element.html
                                                |> Element.inFront
                                            ]
                                            { scale = args.scale
                                            , position = ( x, y )
                                            , onPress = Nothing
                                            }

                                    else
                                        viewCell []
                                            { scale = args.scale
                                            , position = ( x, y )
                                            , onPress = args.onPress
                                            }

                                Nothing ->
                                    viewCell []
                                        { scale = args.scale
                                        , position = ( x, y )
                                        , onPress = args.onPress
                                        }
                            )
                                maybeCellType
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
                (Element.row
                    []
                )
        )
