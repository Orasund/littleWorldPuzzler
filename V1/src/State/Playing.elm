module State.Playing exposing (Model, Msg, TransitionData, init, update, view)

import Action
import Config
import Data.Board as Board
import Data.CellType as CellType exposing (CellType(..))
import Data.Deck as Deck exposing (Selected(..))
import Data.Game as Game exposing (EndCondition(..), Game)
import Element exposing (Element)
import Element.Events
import Framework
import Grid.Bordered as Grid
import Http exposing (Error(..))
import Layout
import Process
import Random exposing (Generator, Seed)
import Random.List
import Set exposing (Set)
import State.Finished as FinishedState
import Svg.Attributes
import Task
import UndoList exposing (UndoList)
import View exposing (card)
import View.CellType
import View.Game as GameView
import View.Header as HeaderView
import View.Overlay
import View.Shade as Shade



----------------------
-- Model
----------------------


type Overlay
    = CardDetail { pos : ( Int, Int ), card : CellType }
    | CardSelector ( Int, Int )
    | NewCardPicker (List CellType)


type alias State =
    { game : Game
    , selected : Maybe Selected
    , history : UndoList Game
    , collection : Set String
    , viewCollection : Bool
    , viewedCard : Maybe CellType
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
    | Undo
    | Redo
    | PageChangeRequested
    | CardSelected CellType
    | CloseOverlay
    | PickCardToAdd CellType


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
      , history = UndoList.fresh game
      , collection = Set.empty
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
play ({ game, history } as state) =
    let
        seconds : Float
        seconds =
            1000
    in
    Action.updating
        ( { state
            | game = game
            , selected = Nothing
            , history = history |> UndoList.new game
          }
        , Task.perform (always CardPlaced) <| Process.sleep (0.1 * seconds)
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
            CellType.list
                |> Random.List.choices 2
                |> Random.map
                    (\( list, _ ) ->
                        { model
                            | game = { game | board = board }
                            , overlay = NewCardPicker list |> Just
                        }
                    )
    )
        |> apply model.seed
        |> play


playSecond : ( Int, Int ) -> CellType -> Model -> Action
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
update msg (({ history, selected, viewCollection, collection } as state) as model) =
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

                newHistory : UndoList Game
                newHistory =
                    history |> UndoList.new newGame
            in
            if newGame.board |> Grid.emptyPositions |> (==) [] then
                Action.transitioning
                    { game = newGame
                    , history = newHistory
                    , challenge = False
                    }

            else
                Action.updating
                    ( { state
                        | game = newGame
                        , history = newHistory
                        , collection = newCollection
                      }
                    , Cmd.none
                    )

        Redo ->
            let
                newHistory : UndoList Game
                newHistory =
                    history
                        |> UndoList.redo
                        |> UndoList.redo
            in
            Action.updating
                ( { state
                    | history = newHistory
                    , game = newHistory |> .present
                  }
                , Cmd.none
                )

        Undo ->
            let
                newHistory : UndoList Game
                newHistory =
                    history
                        |> UndoList.undo
                        |> UndoList.undo
            in
            Action.updating
                ( { state
                    | history = newHistory
                    , game = newHistory |> .present
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
    [ HeaderView.view
        restartMsg
        model.game.score
    , GameView.view
        { scale = scale
        , selected = model.selected
        , positionSelected =
            case model.overlay of
                Just (CardSelector position) ->
                    Just position

                _ ->
                    Nothing
        , positionSelectedMsg = msgMapper << PositionSelected
        , placeCard = \a b -> PlaceCard a b |> msgMapper
        }
        model.game
    ]
        |> Element.column
            (Framework.container
                ++ (model.overlay
                        |> Maybe.map
                            (\overlay ->
                                case overlay of
                                    CardDetail cardDetail ->
                                        View.Overlay.cardDetail cardDetail.card
                                            |> List.singleton
                                            |> Shade.viewNormal
                                                [ Element.Events.onClick (CloseOverlay |> msgMapper)
                                                ]
                                            |> Element.inFront

                                    CardSelector _ ->
                                        []
                                            |> Shade.viewTransparent
                                                [ Element.Events.onClick (CloseOverlay |> msgMapper)
                                                ]
                                            |> Element.inFront

                                    NewCardPicker list ->
                                        list
                                            |> View.Overlay.newCardPicker { select = PickCardToAdd >> msgMapper }
                                            |> List.singleton
                                            |> Shade.viewNormal []
                                            |> Element.inFront
                            )
                        |> Maybe.map List.singleton
                        |> Maybe.withDefault []
                   )
            )
