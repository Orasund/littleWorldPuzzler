module View.Shade exposing (viewNormal, viewTransparent, viewWon)

import Element exposing (Attribute, Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Framework.Card as Card
import Framework.Grid as Grid


viewNormal : List (Attribute msg) -> List (Element msg) -> Element msg
viewNormal attrs content =
    view
        ([ Background.color <| Element.rgba255 0 0 0 0.7
         ]
            ++ attrs
        )
        content


viewWon : List (Attribute msg) -> List (Element msg) -> Element msg
viewWon attrs content =
    view
        ([ Background.color <| Element.rgba255 204 166 0 0.7
         ]
            ++ attrs
        )
        content


viewTransparent : List (Attribute msg) -> List (Element msg) -> Element msg
viewTransparent attrs content =
    view
        ([ Background.color <| Element.rgba 0 0 0 0
         ]
            ++ attrs
        )
        content


view : List (Attribute msg) -> List (Element msg) -> Element msg
view attributes content =
    Element.el
        (attributes
            |> List.append
                (Card.simple
                    ++ [ Element.width <| Element.fill
                       , Element.height <| Element.fill
                       , Border.width <| 0
                       , Border.rounded <| 0
                       , Element.centerX
                       , Element.centerY
                       , Font.family
                            [ Font.sansSerif ]
                       ]
                )
        )
    <|
        Element.column (Grid.spaceEvenly ++ [ Element.height <| Element.shrink ]) <|
            content
