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
    [ View.Card.asBigCard [] card
    ]
        |> Layout.column (Layout.centered ++ [ Layout.gap Config.space ])


newCardPicker : { select : Card -> msg } -> Card -> Html msg
newCardPicker args card =
    [ Layout.text [ Html.Attributes.style "font-size" Config.titleFontSize ] "Deck Cleared"
    , "As a reward, one "
        ++ Card.toString card
        ++ " "
        ++ Card.name card
        ++ " has been added to your deck"
        |> Layout.text []
    , View.Card.asSmallCard [] card
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
    [ Layout.text [ Html.Attributes.style "font-size" Config.titleFontSize ] "Game Over"
    , Layout.text [ Html.Attributes.style "font-size" Config.titleFontSize ] medal
    , Layout.text [ Html.Attributes.style "font-size" Config.bigFontSize ] "Score"
    , String.fromInt score
        |> Layout.text [ Html.Attributes.style "font-size" Config.paragraphFontSize ]
    , Layout.text [] text
    , { onPress = Just restartMsg
      , label = "Restart"
      }
        |> View.Button.textButton [ Html.Attributes.style "font-family" "sans-serif" ]
    ]
        |> Layout.column (Layout.gap Config.space :: Layout.centered)
        |> View.card []
