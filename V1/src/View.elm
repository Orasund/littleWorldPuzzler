module View exposing (..)

import Config
import Html exposing (Attribute, Html)
import Html.Attributes
import Layout
import View.Color


card : List (Attribute msg) -> Html msg -> Html msg
card attrs =
    Layout.el
        ([ Html.Attributes.style "background-color" View.Color.background
         , Html.Attributes.style "border-radius" (String.fromFloat Config.borderRadius ++ "px")
         , Html.Attributes.style "padding" (String.fromFloat Config.space ++ "px")
         ]
            ++ Layout.centered
            ++ attrs
        )
