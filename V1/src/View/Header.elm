module View.Header exposing (view)

import Html exposing (Html)
import Html.Attributes
import Layout
import View.Button


view : msg -> Int -> Html msg
view restartMsg score =
    [ Layout.el [ Layout.fill ] Layout.none
    , String.fromInt score
        |> Layout.text [ Html.Attributes.style "font-size" "2rem" ]
    , View.Button.textButton [] { label = "Restart", onPress = Just restartMsg }
        |> Layout.el [ Layout.fill, Layout.contentAtEnd ]
    ]
        |> Layout.row [ Html.Attributes.style "width" "100%" ]
