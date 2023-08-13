module View.Overlay exposing (..)

import Config
import Data.Card as CellType exposing (Card)
import Element exposing (Element)
import Html exposing (Html)
import Html.Attributes
import Layout
import View.Card
import View.Color


cardDetail : Card -> Html msg
cardDetail card =
    [ card
        |> View.Card.asBigCard []
    ]
        |> Layout.column (Layout.centered ++ [ Layout.gap Config.space ])


newCardPicker : { select : Card -> msg } -> List Card -> Html msg
newCardPicker args list =
    [ "Pick one card to add to your deck"
        |> Layout.text [ Html.Attributes.style "color" View.Color.background ]
    , list
        |> List.map
            (\cellType ->
                cellType
                    |> View.Card.asSmallCard
                        (Layout.asButton
                            { label = "Select " ++ CellType.name cellType
                            , onPress = args.select cellType |> Just
                            }
                        )
            )
        |> Layout.row [ Layout.gap Config.smallSpace ]
    ]
        |> Layout.column [ Layout.gap Config.space ]
