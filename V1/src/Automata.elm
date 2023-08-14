module Automata exposing (step)

import Automata.Neighborhood as Neighborhood
import Automata.Rule as Rule
import CellAutomata exposing (Automata, Order, Rule)
import Data.Card as CellType exposing (Card)
import Dict exposing (Dict)


order : Order Card String
order =
    Maybe.map CellType.name
        >> Maybe.withDefault ""


rules : List (Rule Card)
rules =
    List.map Rule.rules CellType.list
        |> List.concat


automata : Automata Card String
automata =
    CellAutomata.automata
        Neighborhood.fullSymmetry
        order
        rules


step : Dict ( Int, Int ) Card -> ( Int, Int ) -> Maybe Card -> Maybe Card
step =
    CellAutomata.step
        automata
