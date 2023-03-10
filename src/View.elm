module View exposing (..)

import Card exposing (Card)
import Html exposing (Html)
import Html.Attributes
import Layout


button : Maybe msg -> String -> Html msg
button onPress label =
    Html.text label
        |> Layout.button
            [ Html.Attributes.style "border-radius" "16px"
            , Html.Attributes.style "border" "1px solid rgba(0,0,0,0.2)"
            ]
            { label = label
            , onPress = onPress
            }


cell : { clicked : msg, neighbors : List Card } -> Maybe Card -> Html msg
cell args maybeCard =
    maybeCard
        |> Maybe.map Card.emoji
        |> Maybe.withDefault ""
        |> Html.text
        |> Layout.button
            (Layout.centered
                ++ [ Html.Attributes.style "width" "64px"
                   , Html.Attributes.style "height" "64px"
                   , Html.Attributes.style "border-radius" "16px"
                   , Html.Attributes.style "font-size" "48px"
                   , Html.Attributes.style
                        "border"
                        "1px solid rgba(0,0,0,0.2)"
                   ]
            )
            { onPress =
                if maybeCard == Nothing then
                    args.clicked |> Just

                else
                    Nothing
            , label =
                maybeCard
                    |> Maybe.map Card.emoji
                    |> Maybe.withDefault " "
            }
        |> Layout.withStack []
            (maybeCard
                |> Maybe.map Card.produces
                |> Maybe.map
                    (\( to, fun ) ->
                        if fun args.neighbors then
                            [ \attrs ->
                                Card.emoji to
                                    |> Layout.text
                                        (Layout.centered
                                            ++ [ Html.Attributes.style "border-radius" "100%"
                                               , Html.Attributes.style "right" "-8px"
                                               , Html.Attributes.style "top" "-8px"
                                               , Html.Attributes.style "height" "24px"
                                               , Html.Attributes.style "aspect-ratio" "1"
                                               , Html.Attributes.style "background-color" "white"
                                               , Html.Attributes.style "border" "1px solid rgba(0,0,0,0.2)"
                                               ]
                                            ++ attrs
                                        )
                            ]

                        else
                            []
                    )
                |> Maybe.withDefault []
            )
