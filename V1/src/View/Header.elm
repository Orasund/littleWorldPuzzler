module View.Header exposing (view)

import Element exposing (Element)
import Element.Font as Font
import Framework.Grid as Grid
import Html.Attributes
import Layout
import View.Button


display : msg -> Int -> Element msg
display restartMsg score =
    Element.row
        (Grid.spaceEvenly
            ++ [ Element.height <| Element.shrink
               ]
        )
    <|
        [ Layout.el [ Layout.fill ] Layout.none |> Element.html
        , Element.el [ Font.size <| floor <| 42 ] <|
            Element.text <|
                String.fromInt score
        , View.Button.textButton [] { label = "Restart", onPress = Just restartMsg }
            |> Layout.el [ Layout.fill, Layout.contentAtEnd ]
            |> Element.html
        ]


view : msg -> Int -> Element msg
view restartMsg score =
    display restartMsg score
