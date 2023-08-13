module State.Playing exposing (Model, Msg, TransitionData, init, update, view)

import Action
import Config
import Data.Board as Board
import Data.CellType exposing (CellType(..))
import Data.Deck as Deck exposing (Selected(..))
import Data.Game as Game exposing (EndCondition(..), Game)
import Element exposing (Element)
import Element.Events
import Framework
import Grid.Bordered as Grid
import Http exposing (Error(..))
import Layout
import Process
import Random exposing (Seed)
import Set exposing (Set)
import State.Finished as FinishedState
import Task
import UndoList exposing (UndoList)
import View.CellType
import View.Game as GameView
import View.Header as HeaderView
import View.Shade as Shade



----------------------
-- Model
----------------------


type Overlay
    = CardDetail { pos : ( Int, Int ), card : CellType }
    | CardSelector ( Int, Int )


type alias State =
    { game : Game
    , selected : Maybe Selected
    , history : UndoList Game
    , collection : Set String
    , viewCollection : Bool
    , viewedCard : Maybe CellType
    , overlay : Maybe Overlay
    , initialSeed : Seed
    }


type alias Model =
    ( State, Seed )


type Msg
    = Selected Selected
    | PositionSelected ( Int, Int )
    | PlaceCard ( Int, Int ) Selected
    | PickUp ( Int, Int )
    | CardPlaced
    | Undo
    | Redo
    | PageChangeRequested
    | CardSelected CellType
    | CloseOverlay


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
    ( ( { game = game
        , selected = Nothing
        , history = UndoList.fresh game
        , collection = Set.empty
        , viewCollection = False
        , viewedCard = Nothing
        , overlay = Nothing
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
                , overlay = Nothing
                , history = history |> UndoList.new game
            }
          , seed
          )
        , Task.perform (always CardPlaced) <| Process.sleep (0.1 * seconds)
        )


playFirst : ( Int, Int ) -> Model -> Action
playFirst position ( { game, initialSeed } as state, seed ) =
    Random.step
        (Deck.playFirst True game.deck
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
        seed
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
update msg (( { game, history, selected, viewCollection, collection } as state, seed ) as model) =
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
                            Action.updating
                                ( ( { state
                                        | overlay =
                                            position
                                                |> CardSelector
                                                |> Just
                                    }
                                  , seed
                                  )
                                , Cmd.none
                                )

                Ok (Just cell) ->
                    Action.updating ( ( { state | overlay = CardDetail { pos = position, card = cell } |> Just }, seed ), Cmd.none )

                Err _ ->
                    defaultCase

        PickUp position ->
            case game.board |> Grid.get position of
                Ok (Just cell) ->
                    pickUp cell position model

                _ ->
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
            if newGame.board |> Grid.emptyPositions |> (==) [] then
                Action.transitioning
                    { game = newGame
                    , history = newHistory
                    , challenge = False
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

        CloseOverlay ->
            Action.updating
                ( ( { state | overlay = Nothing }, seed ), Cmd.none )



----------------------
-- View
----------------------


view :
    Float
    -> msg
    -> (Msg -> msg)
    -> Model
    -> Element msg
view scale restartMsg msgMapper ( model, _ ) =
    [ HeaderView.view
        restartMsg
        model.game.score
    , GameView.view
        { scale = scale
        , selected = model.selected
        , sort = True
        , positionSelected =
            case model.overlay of
                Just (CardSelector position) ->
                    Just position

                _ ->
                    Nothing
        , positionSelectedMsg = msgMapper << PositionSelected
        , selectedMsg = msgMapper << Selected
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
                                        [ cardDetail.card
                                            |> View.CellType.asCard
                                        ]
                                            |> Layout.column (Layout.centered ++ [ Layout.gap Config.space ])
                                            |> Element.html
                                            --needed to play nice with elm-ui
                                            |> Element.el [ Element.centerX ]
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
                            )
                        |> Maybe.map List.singleton
                        |> Maybe.withDefault []
                   )
            )
