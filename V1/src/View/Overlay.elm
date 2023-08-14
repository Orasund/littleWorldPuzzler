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
    let
        ( medal, text ) =
            if score < 250 then
                ( "🥉", "Achieve a score of 250 to get a silver medal." )

            else if score < 500 then
                ( "🥈", "Achieve a score of 500 to get a gold medal." )

            else if score < 1000 then
                ( "🥇", "Achieve a score of 1000 to get a perfect score." )

            else
                ( "💯", "Perfection!" )
    in
    [ "Game Over" |> Layout.text [ Html.Attributes.style "font-size" Config.titleFontSize ]
    , medal |> Layout.text [ Html.Attributes.style "font-size" Config.titleFontSize ]
    , "Score" |> Layout.text [ Html.Attributes.style "font-size" Config.bigFontSize ]
    , score |> String.fromInt |> Layout.text [ Html.Attributes.style "font-size" Config.paragraphFontSize ]
    , text |> Layout.text []
    , View.Button.textButton [ Html.Attributes.style "font-family" "sans-serif" ] <|
        { onPress = Just restartMsg
        , label = "Restart"
        }
    ]
        |> Layout.column (Layout.gap Config.space :: Layout.centered)
        |> View.card []
