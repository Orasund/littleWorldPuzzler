module Card exposing (card, hand, view)

import Element exposing (Attribute, Element)
import Element.Border as Border
import Element.Font as Font
import Element.Input as Input
import Framework.Button as Button
import Framework.Color as Color


type alias Card msg =
    { attributes : List (Attribute msg)
    , selected : Bool
    , onPress : Maybe msg
    , content : Element msg
    }


card :
    { attributes : List (Attribute msg), selected : Bool, onPress : Maybe msg, content : Element msg }
    -> Card msg
card { attributes, selected, onPress, content } =
    { attributes = attributes
    , selected = selected
    , onPress = onPress
    , content = content
    }


view : { availableSpace : Float, amount : Int, dim : ( Float, Float ) } -> Card msg -> Element msg
view { availableSpace, amount, dim } { attributes, selected, onPress, content } =
    let
        ( width, height ) =
            dim
    in
    Element.el
        [ height * 1.1 |> floor |> Element.px |> Element.height
        , Element.width <|
            Element.px <|
                if selected then
                    width |> round

                else if availableSpace / toFloat amount >= width then
                    width |> round

                else
                    -- used a geometric series: s - 2w + c / (a - 1 ) = c
                    (availableSpace - 2 * width)
                        / toFloat (amount - 2)
                        |> round
        ]
    <|
        Input.button
            (List.concat
                [ Button.simple
                , Color.light
                , if selected then
                    [ Element.alignTop ]

                  else
                    [ Element.alignBottom ]
                , [ width |> floor |> Element.px |> Element.width
                  , height |> floor |> Element.px |> Element.height
                  , Font.alignLeft
                  , Color.lightGrey |> Border.color
                  ]
                , attributes
                ]
            )
            { label = content
            , onPress = onPress
            }


hand : List (Attribute msg) -> { dimensions : ( Float, Float ), width : Float, cards : List (Card msg) } -> Element msg
hand attributes { dimensions, width, cards } =
    let
        cardsAmount : Int
        cardsAmount =
            cards |> List.length

        ( cardWidth, _ ) =
            dimensions
    in
    cards
        |> List.map
            (view
                { amount = cardsAmount
                , availableSpace = width
                , dim = dimensions
                }
            )
        |> Element.row
            ([ width |> round |> Element.px |> Element.width
             , Element.fill |> Element.height
             , Element.centerX
             ]
                ++ (if width / toFloat cardsAmount >= cardWidth then
                        [ Element.spaceEvenly
                        ]

                    else
                        []
                   )
                ++ attributes
            )
