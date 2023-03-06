module View exposing (..)

import Html exposing (Html)
import Html.Attributes
import Layout


button : Maybe msg -> String -> Html msg
button onPress label =
    Html.text label
        |> Layout.buttonEl
            { label = label
            , onPress = onPress
            }
            [ Html.Attributes.style "border-radius" "16px"
            , Html.Attributes.style "border" "1px solid rgba(0,0,0,0.2)"
            ]
