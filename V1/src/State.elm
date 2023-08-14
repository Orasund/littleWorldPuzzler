module State exposing (Model, Msg, init, update, view)

import Config
import Data.Board as Board
import Data.Card exposing (Card(..))
import Data.Deck as Deck exposing (Selected(..))
import Data.Game as Game exposing (EndCondition(..), Game)
import Dict exposing (Dict)
import Grid.Bordered as Grid
import Html exposing (Html)
import Html.Attributes
import Layout
import Random exposing (Generator, Seed)
import Random.List
import View.Board
import View.Deck
import View.Header as HeaderView
import View.Overlay
import View.Shade as Shade


width : Float
width =
    400



----------------------
-- Model
----------------------


type Overlay
    = CardDetail { pos : ( Int, Int ), card : Card }
    | CardSelector ( Int, Int )
    | NewCardPicker Card
    | GameFinished


type alias State =
    { game : Game
    , selected : Maybe Selected
    , collection : Dict String Card
    , viewCollection : Bool
    , viewedCard : Maybe Card
    , overlay : Maybe Overlay
    , seed : Seed
    }


type alias Model =
    State


type Msg
    = PositionSelected ( Int, Int )
    | PlaceCard ( Int, Int ) Selected
    | CardPlaced
    | PageChangeRequested
    | CardSelected Card
    | CloseOverlay
    | PickCardToAdd Card



----------------------
-- Init
----------------------


init : Seed -> ( Model, Cmd Msg )
init initialSeed =
    let
        ( game, seed ) =
            Random.step Game.generator initialSeed
    in
    ( { game = game
      , selected = Nothing
      , collection = Dict.empty
      , viewCollection = False
      , viewedCard = Nothing
      , overlay = Nothing
      , seed = seed
      }
    , Cmd.none
    )



----------------------
-- Update
----------------------


apply : Seed -> Generator State -> Model
apply seed generator =
    let
        ( model, newSeed ) =
            Random.step generator seed
    in
    { model | seed = newSeed }


play : Model -> Model
play ({ game } as state) =
    { state
        | game = game
        , selected = Nothing
    }


openNewCardPicker : Model -> Generator Model
openNewCardPicker model =
    model.collection
        |> Dict.values
        |> Random.List.choose
        |> Random.map
            (\( maybe, _ ) ->
                { model
                    | overlay = maybe |> Maybe.map NewCardPicker
                }
            )


playFirst : ( Int, Int ) -> Model -> Model
playFirst position ({ game } as model) =
    let
        board =
            game.board
                |> Board.place position
                    (game.deck |> Deck.first)
    in
    (case Deck.playFirst game.deck of
        Just deck ->
            { model
                | game =
                    { game
                        | deck = deck
                        , board = board
                    }
                , overlay = Nothing
            }
                |> Random.constant

        Nothing ->
            openNewCardPicker { model | game = { game | board = board } }
    )
        |> apply model.seed
        |> play


playSecond : ( Int, Int ) -> Card -> Model -> Model
playSecond position cellType ({ game } as state) =
    { state
        | game =
            { game
                | deck = game.deck |> Deck.playSecond |> Maybe.withDefault game.deck
                , board = game.board |> Board.place position cellType
            }
        , overlay = Nothing
    }
        |> play


placeCard : ( Int, Int ) -> Selected -> Model -> Model
placeCard position selected ({ game } as model) =
    case selected of
        First ->
            playFirst position model

        Second ->
            case game.deck |> Deck.second of
                Just second ->
                    playSecond position second model

                Nothing ->
                    playFirst position model


update : Msg -> Model -> Model
update msg (({ selected, viewCollection, collection } as state) as model) =
    let
        defaultCase : Model
        defaultCase =
            model
    in
    case msg of
        PositionSelected position ->
            case model.game.board |> Grid.get position of
                Ok Nothing ->
                    case selected of
                        Just s ->
                            placeCard position s model

                        Nothing ->
                            { state
                                | overlay =
                                    position
                                        |> CardSelector
                                        |> Just
                            }

                Ok (Just cell) ->
                    { state | overlay = CardDetail { pos = position, card = cell } |> Just }

                Err _ ->
                    defaultCase

        PlaceCard position selection ->
            placeCard position selection { state | selected = Just selection }

        CardPlaced ->
            let
                ( newGame, newCollection ) =
                    model.game |> Game.step collection
            in
            if newGame.board |> Grid.emptyPositions |> (==) [] then
                { state
                    | game = newGame
                    , overlay = Just GameFinished
                }

            else
                { state
                    | game = newGame
                    , collection = newCollection
                }

        PageChangeRequested ->
            { state
                | viewCollection = not viewCollection
                , viewedCard = Nothing
            }

        CardSelected cellType ->
            { state
                | viewedCard = Just cellType
            }

        CloseOverlay ->
            { state | overlay = Nothing }

        PickCardToAdd cellType ->
            state.game
                |> Game.addCardAndShuffle cellType
                |> Random.map
                    (\game ->
                        { state
                            | game = game
                            , overlay = Nothing
                        }
                    )
                |> apply model.seed



----------------------
-- View
----------------------


view :
    (Seed -> msg)
    -> (Msg -> msg)
    -> Model
    -> Html msg
view restartMsg msgMapper model =
    [ [ HeaderView.view
            (restartMsg model.seed)
            model.game.score
      , View.Board.toHtml []
            { onPress = (\a -> PositionSelected a |> msgMapper) |> Just
            , onPlace = \a b -> PlaceCard a b |> msgMapper
            , positionSelected =
                case model.overlay of
                    Just (CardSelector position) ->
                        Just position

                    _ ->
                        Nothing
            , deck = model.game.deck
            }
            model.game.board
            |> Layout.el Layout.centered
      , View.Deck.view model.game.deck
      ]
        |> Layout.column
            [ Layout.gap Config.bigSpace
            , Html.Attributes.style "padding" (String.fromFloat Config.space ++ "px")
            , Html.Attributes.style "width" (String.fromFloat width ++ "px")
            ]
    , model.overlay
        |> Maybe.map
            (\overlay ->
                case overlay of
                    CardDetail cardDetail ->
                        View.Overlay.cardDetail cardDetail.card
                            |> Shade.normal
                                (Layout.asButton
                                    { onPress = CloseOverlay |> msgMapper |> Just
                                    , label = "Dismiss"
                                    }
                                )

                    CardSelector _ ->
                        Layout.none
                            |> Shade.transparent
                                (Layout.asButton
                                    { onPress = CloseOverlay |> msgMapper |> Just
                                    , label = "Dismiss"
                                    }
                                )

                    NewCardPicker card ->
                        card
                            |> View.Overlay.newCardPicker { select = PickCardToAdd >> msgMapper }
                            |> Shade.success []

                    GameFinished ->
                        View.Overlay.gameover { restartMsg = restartMsg model.seed }
                            { score = model.game.score }
                            |> Shade.success []
            )
        |> Maybe.withDefault Layout.none
    ]
        |> Html.div
            [ Html.Attributes.style "width" "100%"
            , Html.Attributes.style "height" "100%"
            , Html.Attributes.style "position" "relative"
            ]
