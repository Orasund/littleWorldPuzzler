module View.Game exposing (view, viewFinished, viewHome, viewReplay)

import Data.CellType exposing (CellType(..))
import Data.Deck exposing (Selected(..))
import Data.Game exposing (EndCondition(..), Game)
import Element exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Framework.Grid as Grid
import Framework.Heading as Heading
import View.Board as BoardView
import View.Deck as DeckView


viewFinished : Float -> Game -> Element msg
viewFinished scale { board, deck } =
    Element.column Grid.simple
        [ BoardView.toHtmlWithoutInteraction { scale = scale }
            board
        , DeckView.view scale False Nothing Nothing deck
        ]


viewReplay : Float -> Game -> Element msg
viewReplay scale { board, deck } =
    Element.column
        ([ Element.spacing (floor <| 5 * scale)
         , Background.color <| Element.rgb255 242 242 242
         , Element.padding (floor <| 20 * scale)
         , Border.rounded (floor <| 10 * scale)
         , Element.centerX
         ]
            |> ((::) <|
                    Element.inFront <|
                        Element.el
                            [ Element.width <| Element.fill
                            , Element.height <| Element.fill
                            , Background.color <| Element.rgb255 255 255 255
                            , Element.alpha 0.3
                            ]
                        <|
                            Element.el
                                (Heading.h1
                                    ++ [ Element.centerX
                                       , Element.centerY
                                       , Font.family
                                            [ Font.sansSerif ]
                                       ]
                                )
                            <|
                                Element.text "REPLAY"
               )
        )
    <|
        [ BoardView.toHtmlWithoutInteraction { scale = scale }
            board
        , DeckView.view scale False Nothing Nothing deck
        ]


viewHome : Float -> Game -> Element msg
viewHome scale { board, deck } =
    Element.column Grid.simple <|
        [ BoardView.toHtmlWithoutInteraction { scale = scale }
            board
        , DeckView.view scale False Nothing Nothing deck
        ]


view :
    { scale : Float
    , selected : Maybe Selected
    , sort : Bool
    , positionSelected : Maybe ( Int, Int )
    , placeCard : ( Int, Int ) -> Selected -> msg
    , positionSelectedMsg : ( Int, Int ) -> msg
    , selectedMsg : Selected -> msg
    }
    -> Game
    -> Element msg
view args { board, deck } =
    Element.column Grid.simple <|
        [ BoardView.toHtml
            { scale = args.scale
            , onPress = Just args.positionSelectedMsg
            , onPlace = args.placeCard
            , positionSelected = args.positionSelected
            , deck = deck
            }
            board
        , DeckView.view args.scale args.sort (Just args.selectedMsg) args.selected deck
        ]
