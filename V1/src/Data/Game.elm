module Data.Game exposing (EndCondition(..), Game, addCardAndShuffle, generator, step)

import Automata
import Data.Board exposing (Board, columns, rows)
import Data.Card as CellType exposing (Card(..))
import Data.Deck as Deck exposing (Deck, Selected(..))
import Dict exposing (Dict)
import Grid.Bordered as Grid
import Random exposing (Generator)


type EndCondition
    = Lost
    | NewHighscore


type alias Game =
    { board : Board
    , deck : Deck
    , score : Int
    }


addCardAndShuffle : Card -> Game -> Generator Game
addCardAndShuffle card game =
    game.deck
        |> Deck.addToDiscard card
        |> Deck.shuffle
        |> Random.map (\deck -> { game | deck = deck })


occuringTypes : Board -> Dict String Card
occuringTypes board =
    board
        |> Grid.values
        |> List.map (\card -> ( CellType.toString card, card ))
        |> Dict.fromList


step : Dict String Card -> Game -> ( Game, Dict String Card )
step set ({ score } as game) =
    let
        newBoard : Board
        newBoard =
            game.board
                |> Grid.map (Automata.step (game.board |> Grid.toDict))

        changes : Int
        changes =
            Dict.merge
                (\_ _ -> (+) 1)
                (\_ a b ->
                    if a == b then
                        identity

                    else
                        (+) 1
                )
                (\_ _ -> (+) 1)
                (Grid.toDict newBoard)
                (Grid.toDict game.board)
                0
    in
    ( { game
        | board = newBoard
        , score = score + changes
      }
    , set |> Dict.union (occuringTypes newBoard)
    )


generator : Generator Game
generator =
    Deck.generator
        |> Random.map
            (\deck ->
                { board =
                    Grid.empty { columns = columns, rows = rows }
                , deck = deck
                , score = 0
                }
            )
