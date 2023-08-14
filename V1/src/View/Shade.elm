module View.Shade exposing (normal, success, transparent)

import Html exposing (Attribute, Html)
import Html.Attributes
import Layout
import View.Color


normal : List (Attribute msg) -> Html msg -> Html msg
normal attrs =
    transparent
        ([ Html.Attributes.style "background-color" View.Color.shadeColor
         , Html.Attributes.style "backdrop-filter" "blur(2px)"
         ]
            ++ attrs
        )


success : List (Attribute msg) -> Html msg -> Html msg
success attrs =
    transparent
        ([ Html.Attributes.style "background-color" View.Color.successShadeColor
         , Html.Attributes.style "backdrop-filter" "blur(2px)"
         ]
            ++ attrs
        )


transparent : List (Html.Attribute msg) -> Html msg -> Html msg
transparent attributes =
    Layout.el
        ([ Html.Attributes.style "width" "100%"
         , Html.Attributes.style "height" "100%"
         , Html.Attributes.style "font-family" "sans-serif"
         , Html.Attributes.style "z-index" "5"
         , Html.Attributes.style "position" "absolute"
         , Html.Attributes.style "top" "0"
         , Html.Attributes.style "left" "0"
         , Html.Attributes.style "background-color" "transparent"
         ]
            ++ Layout.centered
            ++ attributes
        )
