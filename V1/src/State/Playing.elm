module State.Playing exposing (Mode(..), Model, Msg, TransitionData, init, update, view)

import Action
import Data.Board as Board
import Data.CellType exposing (CellType(..))
import Data.Deck as Deck exposing (Selected(..))
import Data.Game as Game exposing (EndCondition(..), Game)
import Element exposing (Element)
import Grid.Bordered as Grid
import Http exposing (Error(..))
import Process
import Random exposing (Seed)
import Set exposing (Set)
import State.Finished as FinishedState
import Task
import UndoList exposing (UndoList)
import View.Collection as CollectionView
import View.Game as GameView
import View.Header as HeaderView
import View.PageSelector as PageSelectorView



----------------------
-- Model
----------------------


type Mode
    = Normal
    | Training
    | Challenge


type alias State =
    { game : Game
    , selected : Maybe Selected
    , positionSelected : Maybe ( Int, Int )
    , history : UndoList Game
    , mode : Mode
    , collection : Set String
    , viewCollection : Bool
    , viewedCard : Maybe CellType
    , initialSeed : Seed
    }


type alias Model =
    ( State, Seed )


type Msg
    = Selected Selected
    | PositionSelected ( Int, Int )
    | PlaceCard ( Int, Int ) Selected
    | CardPlaced
    | Undo
    | Redo
    | PageChangeRequested
    | CardSelected CellType


type alias TransitionData =
    { game : Game
    , seed : Seed
    , mode : Mode
    }


type alias Action =
    Action.Action Model Msg FinishedState.TransitionData ()



----------------------
-- Init
----------------------


init : TransitionData -> ( Model, Cmd Msg )
init { game, seed, mode } =
    ( ( { game = game
        , selected = Nothing
        , positionSelected = Nothing
        , history = UndoList.fresh game
        , mode = mode
        , collection = Set.empty
        , viewCollection = False
        , viewedCard = Nothing
        , initialSeed = seed
        }
      , seed
      )
    , Cmd.none
    )



----------------------
-- Update
----------------------


play : Model -> Action
play ( { game, history } as state, seed ) =
    let
        seconds : Float
        seconds =
            1000
    in
    Action.updating
        ( ( { state
                | game = game
                , selected = Nothing
                , positionSelected = Nothing
                , history = history |> UndoList.new game
            }
          , seed
          )
        , Task.perform (always CardPlaced) <| Process.sleep (0.1 * seconds)
        )


playFirst : ( Int, Int ) -> Model -> Action
playFirst position ( { game, mode, initialSeed } as state, seed ) =
    Random.step
        (Deck.playFirst (mode /= Challenge) game.deck
            |> Random.map
                (\deck ->
                    { state
                        | game =
                            { game
                                | deck = deck
                                , board =
                                    game.board
                                        |> Board.place position
                                            (game.deck |> Deck.first)
                            }
                    }
                )
        )
        (if mode == Challenge then
            initialSeed

         else
            seed
        )
        |> play


playSecond : ( Int, Int ) -> CellType -> Model -> Action
playSecond position cellType ( { game } as state, seed ) =
    play
        ( { state
            | game =
                { game
                    | deck = game.deck |> Deck.playSecond
                    , board = game.board |> Board.place position cellType
                }
          }
        , seed
        )


pickUp : CellType -> ( Int, Int ) -> Model -> Action
pickUp cellType position ( { game, history } as state, seed ) =
    let
        seconds : Float
        seconds =
            1000
    in
    Action.updating
        ( ( { state
                | game =
                    { game
                        | board =
                            case game.board |> Grid.remove position of
                                Ok board ->
                                    board

                                Err _ ->
                                    game.board
                        , deck = game.deck |> Deck.placeOnDiscard cellType
                        , score = game.score - 2
                    }
                , selected = Nothing
                , history = history |> UndoList.new game
            }
          , seed
          )
        , Task.perform (always CardPlaced) <| Process.sleep (0.1 * seconds)
        )


placeCard : ( Int, Int ) -> Selected -> Model -> Action
placeCard position selected (( { game }, _ ) as model) =
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
update msg (( { game, history, selected, mode, viewCollection, collection } as state, seed ) as model) =
    let
        defaultCase : Action
        defaultCase =
            Action.updating
                ( model, Cmd.none )
    in
    case msg of
        Selected select ->
            Action.updating
                ( ( { state | selected = Just select }
                  , seed
                  )
                , Cmd.none
                )

        PositionSelected position ->
            case game.board |> Grid.get position of
                Ok Nothing ->
                    case selected of
                        Just s ->
                            placeCard position s model

                        Nothing ->
                            Action.updating ( ( { state | positionSelected = Just position }, seed ), Cmd.none )

                Ok (Just cell) ->
                    pickUp cell position model

                Err _ ->
                    defaultCase

        PlaceCard position selection ->
            placeCard position selection ( { state | selected = Just selection }, seed )

        CardPlaced ->
            let
                ( newGame, newCollection ) =
                    game |> Game.step collection

                newHistory : UndoList Game
                newHistory =
                    history |> UndoList.new newGame
            in
            if (newGame.board |> Grid.emptyPositions |> (==) []) && mode /= Training then
                Action.transitioning
                    { game = newGame
                    , history = newHistory
                    , challenge = mode == Challenge
                    }

            else
                Action.updating
                    ( ( { state
                            | game = newGame
                            , history = newHistory
                            , collection = newCollection
                        }
                      , seed
                      )
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
                ( ( { state
                        | history = newHistory
                        , game = newHistory |> .present
                    }
                  , seed
                  )
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
                ( ( { state
                        | history = newHistory
                        , game = newHistory |> .present
                    }
                  , seed
                  )
                , Cmd.none
                )

        PageChangeRequested ->
            Action.updating
                ( ( { state
                        | viewCollection = not viewCollection
                        , viewedCard = Nothing
                    }
                  , seed
                  )
                , Cmd.none
                )

        CardSelected cellType ->
            Action.updating
                ( ( { state
                        | viewedCard = Just cellType
                    }
                  , seed
                  )
                , Cmd.none
                )



----------------------
-- View
----------------------


view :
    Float
    -> msg
    -> (Msg -> msg)
    -> Model
    -> ( Maybe { isWon : Bool, shade : List (Element msg) }, List (Element msg) )
view scale restartMsg msgMapper ( model, _ ) =
    ( Nothing
    , [ if model.mode == Challenge then
            HeaderView.viewWithUndo
                { restartMsg = restartMsg
                , previousMsg = msgMapper Undo
                , nextMsg = msgMapper Redo
                }
                model.game.score

        else
            HeaderView.view scale
                restartMsg
                model.game.score
      , if model.viewCollection then
            CollectionView.view scale
                (msgMapper << CardSelected)
                model.collection
                model.viewedCard

        else
            GameView.view
                { scale = scale
                , selected = model.selected
                , sort = model.mode /= Challenge
                , positionSelected = model.positionSelected
                , positionSelectedMsg = msgMapper << PositionSelected
                , selectedMsg = msgMapper << Selected
                , placeCard = \a b -> PlaceCard a b |> msgMapper
                }
                model.game
      , (if model.viewCollection then
            PageSelectorView.viewCollection

         else
            PageSelectorView.viewGame
        )
        <|
            msgMapper PageChangeRequested
      ]
    )
