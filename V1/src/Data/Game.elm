module Data.Game exposing (EndCondition(..), Game, addCardAndShuffle, generator, step)

import Automata
import Data.Board exposing (Board, columns, rows)
import Data.CellType as CellType exposing (CellType(..))
import Data.Deck as Deck exposing (Deck, Selected(..))
import Grid.Bordered as Grid
import Random exposing (Generator)
import Set exposing (Set)


type EndCondition
    = Lost
    | NewHighscore


type alias Game =
    { board : Board
    , deck : Deck
    , score : Int
    }


addCardAndShuffle : CellType -> Game -> Generator Game
addCardAndShuffle card game =
    game.deck
        |> Deck.addToDiscard card
        |> Deck.shuffle
        |> Random.map (\deck -> { game | deck = deck })


occuringTypes : Board -> Set String
occuringTypes board =
    board
        |> Grid.values
        |> List.map CellType.toString
        |> Set.fromList


step : Set String -> Game -> ( Game, Set String )
step set ({ score } as game) =
    let
        board : Board
        board =
            game.board
                |> Grid.map (Automata.step (game.board |> Grid.toDict))
    in
    ( { game
        | board = board
        , score = score + 1
      }
    , set |> Set.union (occuringTypes board)
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
