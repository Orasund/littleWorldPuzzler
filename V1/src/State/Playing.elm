module State.Playing exposing (Model, Msg, TransitionData, init, update, view)

import Action
import Config
import Data.Board as Board
import Data.Card as CellType exposing (Card(..))
import Data.Deck as Deck exposing (Selected(..))
import Data.Game as Game exposing (EndCondition(..), Game)
import Dict exposing (Dict)
import Element exposing (Element)
import Element.Events
import Framework
import Grid.Bordered as Grid
import Html
import Html.Attributes
import Layout
import Process
import Random exposing (Generator, Seed)
import Random.List
import Set exposing (Set)
import State.Finished as FinishedState
import Task
import View.Board
import View.Deck
import View.Game as GameView
import View.Header as HeaderView
import View.Overlay
import View.Shade as Shade



----------------------
-- Model
----------------------


type Overlay
    = CardDetail { pos : ( Int, Int ), card : Card }
    | CardSelector ( Int, Int )
    | NewCardPicker (List Card)


type alias State =
    { game : Game
    , selected : Maybe Selected
    , collection : Dict String Card
    , viewCollection : Bool
    , viewedCard : Maybe Card
    , overlay : Maybe Overlay
    , initialSeed : Seed
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


type alias TransitionData =
    { game : Game
    , seed : Seed
    }


type alias Action =
    Action.Action Model Msg FinishedState.TransitionData ()



----------------------
-- Init
----------------------


init : TransitionData -> ( Model, Cmd Msg )
init { game, seed } =
    ( { game = game
      , selected = Nothing
      , collection = Dict.empty
      , viewCollection = False
      , viewedCard = Nothing
      , overlay = Nothing
      , initialSeed = seed
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


play : Model -> Action
play ({ game } as state) =
    let
        seconds : Float
        seconds =
            1000
    in
    Action.updating
        ( { state
            | game = game
            , selected = Nothing
          }
        , Task.perform (always CardPlaced) <| Process.sleep (0.1 * seconds)
        )


openNewCardPicker : Model -> Generator Model
openNewCardPicker model =
    model.collection
        |> Dict.values
        |> Random.List.choices 1
        |> Random.map
            (\( list, _ ) ->
                { model
                    | overlay = NewCardPicker list |> Just
                }
            )


playFirst : ( Int, Int ) -> Model -> Action
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


playSecond : ( Int, Int ) -> Card -> Model -> Action
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


placeCard : ( Int, Int ) -> Selected -> Model -> Action
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


update : Msg -> Model -> Action
update msg (({ selected, viewCollection, collection } as state) as model) =
    let
        defaultCase : Action
        defaultCase =
            Action.updating
                ( model, Cmd.none )
    in
    case msg of
        PositionSelected position ->
            case model.game.board |> Grid.get position of
                Ok Nothing ->
                    case selected of
                        Just s ->
                            placeCard position s model

                        Nothing ->
                            Action.updating
                                ( { state
                                    | overlay =
                                        position
                                            |> CardSelector
                                            |> Just
                                  }
                                , Cmd.none
                                )

                Ok (Just cell) ->
                    Action.updating
                        ( { state | overlay = CardDetail { pos = position, card = cell } |> Just }
                        , Cmd.none
                        )

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
                Action.transitioning
                    { game = newGame
                    }

            else
                Action.updating
                    ( { state
                        | game = newGame
                        , collection = newCollection
                      }
                    , Cmd.none
                    )

        PageChangeRequested ->
            Action.updating
                ( { state
                    | viewCollection = not viewCollection
                    , viewedCard = Nothing
                  }
                , Cmd.none
                )

        CardSelected cellType ->
            Action.updating
                ( { state
                    | viewedCard = Just cellType
                  }
                , Cmd.none
                )

        CloseOverlay ->
            Action.updating
                ( { state | overlay = Nothing }, Cmd.none )

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
                |> (\m -> Action.updating ( m, Cmd.none ))



----------------------
-- View
----------------------


view :
    Float
    -> msg
    -> (Msg -> msg)
    -> Model
    -> Element msg
view scale restartMsg msgMapper model =
    [ [ HeaderView.view
            restartMsg
            model.game.score
      , View.Board.toHtml []
            { scale = scale
            , onPress = (\a -> PositionSelected a |> msgMapper) |> Just
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

                    NewCardPicker list ->
                        list
                            |> View.Overlay.newCardPicker { select = PickCardToAdd >> msgMapper }
                            |> Shade.normal []
            )
        |> Maybe.withDefault Layout.none
    ]
        |> Html.div [ Html.Attributes.style "position" "relative" ]
        |> Element.html
