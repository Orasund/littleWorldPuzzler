module State exposing (..)

import Config
import Data.Board as Board
import Data.Card as Card exposing (Card(..))
import Data.Deck as Deck exposing (Selected(..))
import Data.Game as Game exposing (Game)
import Dict exposing (Dict)
import Grid.Bordered as Grid
import Html exposing (Html)
import Html.Attributes
import Layout
import Random exposing (Generator, Seed)
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
    = CardDetail Card
    | CardSelector ( Int, Int )
    | DeckCleared Card
    | GameFinished


type alias State =
    { game : Game
    , collection : Dict String Card
    , overlay : Maybe Overlay
    , seed : Seed
    }


type alias Model =
    State


type Action
    = UpdateGameAction



----------------------
-- Init
----------------------


init : Seed -> Model
init initialSeed =
    let
        ( game, seed ) =
            Random.step Game.generator initialSeed
    in
    { game = game
    , collection = Dict.empty
    , overlay = Nothing
    , seed = seed
    }



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


play : Model -> ( Model, List Action )
play ({ game } as state) =
    ( { state
        | game = game
      }
    , [ UpdateGameAction ]
    )


reshuffle : Model -> Generator Model
reshuffle model =
    let
        randomCard =
            case
                Dict.values model.collection
                    |> List.map
                        (\card ->
                            ( Dict.get (Card.toString card) Card.number
                                |> Maybe.withDefault 0
                                |> toFloat
                            , card
                            )
                        )
            of
                head :: tail ->
                    Random.weighted head tail

                _ ->
                    Random.constant Plant
    in
    Random.map (\card -> pickCardToAdd card model) randomCard


playFirst : ( Int, Int ) -> Model -> ( Model, List Action )
playFirst position ({ game } as model) =
    let
        board =
            Board.place position
                (Deck.first game.deck)
                game.board
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
            reshuffle { model | game = { game | board = board } }
    )
        |> apply model.seed
        |> play


playSecond : ( Int, Int ) -> Card -> Model -> ( Model, List Action )
playSecond position cellType ({ game } as state) =
    { state
        | game =
            { game
                | deck =
                    Deck.playSecond game.deck
                        |> Maybe.withDefault game.deck
                , board = Board.place position cellType game.board
            }
        , overlay = Nothing
    }
        |> play


placeCard : ( Int, Int ) -> Selected -> Model -> ( Model, List Action )
placeCard position selected ({ game } as model) =
    case selected of
        First ->
            playFirst position model

        Second ->
            case Deck.second game.deck of
                Just second ->
                    playSecond position second model

                Nothing ->
                    playFirst position model


updateGame : Model -> Model
updateGame model =
    let
        ( newGame, newCollection ) =
            Game.step model.collection model.game
    in
    if
        Grid.emptyPositions newGame.board
            |> (==) []
    then
        { model
            | game = newGame
            , overlay = Just GameFinished
        }

    else
        { model
            | game = newGame
            , collection = newCollection
        }


positionSelected : ( Int, Int ) -> Model -> Model
positionSelected position model =
    case Grid.get position model.game.board of
        Ok Nothing ->
            { model
                | overlay =
                    CardSelector position
                        |> Just
            }

        Ok (Just card) ->
            { model | overlay = CardDetail card |> Just }

        Err _ ->
            model


viewCard : Card -> Model -> Model
viewCard card model =
    { model
        | overlay = Just (CardDetail card)
    }


closeOverlay : Model -> Model
closeOverlay model =
    { model | overlay = Nothing }


pickCardToAdd : Card -> Model -> Model
pickCardToAdd card model =
    Game.addCardAndShuffle card model.game
        |> Random.map
            (\game ->
                { model
                    | game = game
                    , overlay = Nothing
                }
            )
        |> apply model.seed



----------------------
-- View
----------------------


viewGame :
    { restart : Seed -> msg
    , placeCard : ( Int, Int ) -> Selected -> msg
    , viewCard : Card -> msg
    , selectPositon : ( Int, Int ) -> msg
    }
    -> Model
    -> Html msg
viewGame args model =
    [ HeaderView.view
        (args.restart model.seed)
        model.game.score
    , View.Board.toHtml []
        { onPress = (\a -> args.selectPositon a) |> Just
        , onPlace = \a b -> args.placeCard a b
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
    , View.Deck.view
        { viewCard = args.viewCard }
        model.game.deck
    ]
        |> Layout.column
            [ Layout.gap Config.bigSpace
            , Html.Attributes.style "padding" (String.fromFloat Config.space ++ "px")
            , Html.Attributes.style "width" (String.fromFloat width ++ "px")
            ]


viewOverlay :
    { restart : Seed -> msg
    , closeOverlay : msg
    , selectCardToAdd : Card -> msg
    }
    -> Model
    -> Html msg
viewOverlay args model =
    Maybe.map
        (\overlay ->
            case overlay of
                CardDetail card ->
                    View.Overlay.cardDetail card
                        |> Shade.normal
                            (Layout.asButton
                                { onPress = Just args.closeOverlay
                                , label = "Dismiss"
                                }
                            )

                CardSelector _ ->
                    Shade.transparent
                        (Layout.asButton
                            { onPress = Just args.closeOverlay
                            , label = "Dismiss"
                            }
                        )
                        Layout.none

                DeckCleared card ->
                    View.Overlay.newCardPicker { select = args.selectCardToAdd } card
                        |> Shade.success []

                GameFinished ->
                    View.Overlay.gameover { restartMsg = args.restart model.seed }
                        { score = model.game.score }
                        |> Shade.normal []
        )
        model.overlay
        |> Maybe.withDefault Layout.none
