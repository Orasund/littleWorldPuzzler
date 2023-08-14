module View.Overlay exposing (..)

import Config
import Data.Card as Card exposing (Card)
import Html exposing (Html)
import Html.Attributes
import Layout
import View
import View.Button
import View.Card


cardDetail : Card -> Html msg
cardDetail card =
    [ card
        |> View.Card.asBigCard []
    ]
        |> Layout.column (Layout.centered ++ [ Layout.gap Config.space ])


newCardPicker : { select : Card -> msg } -> Card -> Html msg
newCardPicker args card =
    [ "Deck Cleared" |> Layout.text [ Html.Attributes.style "font-size" Config.titleFontSize ]
    , "As a reward, one "
        ++ Card.toString card
        ++ " "
        ++ Card.name card
        ++ " has been added to your deck"
        |> Layout.text []
    , card |> View.Card.asSmallCard []
    , View.Button.secondaryTextButton []
        { label = "Thanks"
        , onPress = args.select card |> Just
        }
    ]
        |> Layout.column (Layout.centered ++ [ Layout.gap Config.space ])


gameover : { restartMsg : msg } -> { score : Int } -> Html msg
gameover { restartMsg } { score } =
    [ "Game Over" |> Layout.text [ Html.Attributes.style "font-size" Config.titleFontSize ]
    , "Score" |> Layout.text [ Html.Attributes.style "font-size" "2rem" ]
    , score |> String.fromInt |> Layout.text [ Html.Attributes.style "font-size" "3rem" ]
    , View.Button.textButton [ Html.Attributes.style "font-family" "sans-serif" ] <|
        { onPress = Just restartMsg
        , label = "Restart"
        }
    ]
        |> Layout.column (Layout.gap Config.space :: Layout.centered)
        |> View.card []
