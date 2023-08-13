module View.Overlay exposing (..)

import Config
import Data.CellType as CellType exposing (CellType)
import Element exposing (Element)
import Html.Attributes
import Layout
import View.CellType
import View.Color


cardDetail : CellType -> Element msg
cardDetail card =
    [ card
        |> View.CellType.asBigCard []
    ]
        |> Layout.column (Layout.centered ++ [ Layout.gap Config.space ])
        |> Element.html
        --needed to play nice with elm-ui
        |> Element.el [ Element.centerX ]


newCardPicker : { select : CellType -> msg } -> List CellType -> Element msg
newCardPicker args list =
    [ "Pick one card to add to your deck"
        |> Layout.text [ Html.Attributes.style "color" View.Color.background ]
    , list
        |> List.map
            (\cellType ->
                cellType
                    |> View.CellType.asSmallCard
                        (Layout.asButton
                            { label = "Select " ++ CellType.name cellType
                            , onPress = args.select cellType |> Just
                            }
                        )
            )
        |> Layout.row [ Layout.gap Config.smallSpace ]
    ]
        |> Layout.column [ Layout.gap Config.space ]
        |> Element.html
        --needed to play nice with elm-ui
        |> Element.el [ Element.centerX ]
