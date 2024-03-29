module View.Button exposing (iconButton, secondaryTextButton, textButton)

import Config
import Html exposing (Html)
import Html.Attributes
import Layout
import View.Color as Color


iconButton : List (Html.Attribute msg) -> { label : String, onPress : Maybe msg, size : Float } -> Html msg -> Html msg
iconButton attrs args =
    Layout.button
        ([ Html.Attributes.style "border-radius" (String.fromFloat args.size ++ "px")
         , Html.Attributes.style "background-color" Color.background
         , Html.Attributes.style "padding" (String.fromFloat Config.smallSpace ++ "px")
         , Html.Attributes.style "width" (String.fromFloat args.size ++ "px")
         , Html.Attributes.style "height" (String.fromFloat args.size ++ "px")
         , Html.Attributes.style "border" ("2px solid " ++ Color.primary)
         ]
            ++ Layout.centered
            ++ attrs
        )
        { onPress = args.onPress, label = args.label }


textButton : List (Html.Attribute msg) -> { label : String, onPress : Maybe msg } -> Html msg
textButton attrs args =
    Layout.textButton
        ([ Html.Attributes.style "background-color" Color.primary
         , Html.Attributes.style "padding" (String.fromFloat Config.smallSpace ++ "px " ++ String.fromFloat Config.space ++ "px")
         , Html.Attributes.style "border-radius" (String.fromFloat Config.borderRadius ++ "px")
         , Html.Attributes.style "border" ("2px solid " ++ Color.primary)
         , Html.Attributes.style "color" Color.background
         ]
            ++ attrs
        )
        args


secondaryTextButton : List (Html.Attribute msg) -> { label : String, onPress : Maybe msg } -> Html msg
secondaryTextButton attrs =
    textButton
        ([ Html.Attributes.style "background-color" Color.secondary
         , Html.Attributes.style "border" ("2px solid " ++ Color.secondary)
         ]
            ++ attrs
        )
