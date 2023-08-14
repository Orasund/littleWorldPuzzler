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


stylesheet : Html msg
stylesheet =
    """
html,body {
    height:100%;
    width:100%;
    marign:0;
}

button:hover {
    filter:brightness(0.90);
}

button:focus {
    filter:brightness(0.75);
}

@font-face {
  font-family: 'Noto Emoji';
  src: url('NotoColorEmoji.ttf');
}
        """
        |> Html.text
        |> List.singleton
        |> Html.node "style" []
