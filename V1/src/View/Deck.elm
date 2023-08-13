module View.Deck exposing (view)

import Config
import Data.Card as CellType exposing (Card(..))
import Data.Deck as Deck exposing (Deck, Selected(..))
import Element exposing (Attribute, Element)
import Element.Font as Font
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


viewAttributes : List (Attribute msg)
viewAttributes =
    [ Element.centerX
    , Element.spaceEvenly

    --, Element.height <| Element.px <| floor <| 200 * scale
    , Element.width <| Element.fill
    ]


view : Float -> Deck -> Element msg
view scale deck =
    Element.row viewAttributes <|
        [ viewInactiveCard <|
            Element.column
                [ Element.spacing <| Config.space
                , Element.centerX
                ]
                [ Element.el
                    [ Font.size <| floor <| 30 * scale
                    , Element.centerX
                    ]
                  <|
                    Element.text "📤"
                , deck
                    |> Deck.remaining
                    |> List.tail
                    |> Maybe.withDefault []
                    |> List.map CellType.toString
                    |> List.map (Layout.text [])
                    |> Layout.row [ Layout.gap Config.smallSpace ]
                    |> Element.html
                ]
        , [ Deck.first deck |> Just
          , deck |> Deck.second
          ]
            |> List.filterMap identity
            |> List.map
                (\cellType ->
                    cellType
                        |> View.CellType.asSmallCard []
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
                , deck
                    |> Deck.played
                    |> List.map CellType.toString
                    |> List.map (Layout.text [])
                    |> Layout.row [ Layout.gap Config.smallSpace ]
                    |> Element.html
                ]
        ]
