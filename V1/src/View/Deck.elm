module View.Deck exposing (view, viewOne)

import Card
import Config
import Data.CellType as CellType exposing (CellType(..))
import Data.Deck as Deck exposing (Deck, Selected(..))
import Element exposing (Attribute, Element)
import Element.Font as Font
import Html exposing (Html)
import Html.Attributes
import Layout
import View
import View.CellType


viewInactiveCard : Element msg -> Element msg
viewInactiveCard content =
    Element.el
        [ Element.width <| Element.px <| floor <| 85
        , Element.height <| Element.px <| floor <| 160
        , Element.alignTop
        , Element.padding <| Config.smallSpace
        ]
    <|
        content


viewCardList : Float -> Bool -> List CellType -> Element msg
viewCardList scale sort =
    List.map CellType.toString
        >> (if sort then
                List.sort

            else
                identity
           )
        >> List.map Element.text
        >> Element.wrappedRow
            [ Font.size <| floor <| 25 * scale
            , Element.spacing <| floor <| 5 * scale
            , Element.centerX
            ]


viewContent : CellType -> Html msg
viewContent cellType =
    [ CellType.toString cellType
        |> Layout.text [ Html.Attributes.style "font-size" "40px" ]
    , View.CellType.asRules cellType
        |> Layout.column
            [ Layout.gap <| Config.smallSpace
            , Html.Attributes.style "font-size" "10px"
            ]
    ]
        |> Layout.column
            (Layout.centered
                ++ [ Layout.gap 40
                   ]
            )


viewAttributes : List (Attribute msg)
viewAttributes =
    [ Element.centerX
    , Element.spaceEvenly

    --, Element.height <| Element.px <| floor <| 200 * scale
    , Element.width <| Element.fill
    ]


viewOne : List (Attribute msg) -> CellType -> Element msg
viewOne attrs cellType =
    let
        cardWidth =
            60
    in
    Element.el
        [ -- Element.height <| Element.px <| floor <| 200 * scale
          Element.centerX
        ]
    <|
        Card.hand attrs
            { width = cardWidth
            , dimensions = ( cardWidth, cardWidth * 2 / 3 )
            , cards =
                List.singleton <|
                    Card.card
                        { attributes = []
                        , content = viewContent cellType |> Element.html
                        , onPress = Nothing
                        , selected = True
                        }
            }


view : Float -> Bool -> Maybe (Selected -> msg) -> Maybe Selected -> Deck -> Element msg
view scale sort maybeSelectedMsg maybeSelected deck =
    let
        cardWidth =
            80
    in
    Element.row viewAttributes <|
        [ viewInactiveCard <|
            Element.column
                [ Element.spacing <| floor <| 10 * scale
                , Element.centerX
                ]
                [ Element.el
                    [ Font.size <| floor <| 30 * scale
                    , Element.centerX
                    ]
                  <|
                    Element.text "📤"
                , viewCardList scale
                    sort
                    (deck
                        |> Deck.remaining
                        |> List.tail
                        |> Maybe.withDefault []
                    )
                ]
        , [ Deck.first deck |> Just
          , deck |> Deck.second
          ]
            |> List.filterMap identity
            |> List.map
                (\cellType ->
                    viewContent cellType
                        |> View.card []
                        |> Element.html
                )
            |> Element.row [ Element.spaceEvenly ]
        , viewInactiveCard <|
            Element.column
                [ Element.spacing <| floor <| 10 * scale
                , Element.centerX
                ]
                [ Element.el [ Font.size <| floor <| 30 * scale, Element.centerX ] <|
                    Element.text "🗑"
                , viewCardList scale sort (deck |> Deck.played)
                ]
        ]
