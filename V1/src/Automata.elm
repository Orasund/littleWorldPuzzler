module Automata exposing (step)

import Automata.Neighborhood as Neighborhood
import Automata.Rule as Rule
import CellAutomata exposing (Automata, Order, Rule)
import Data.CellType as CellType exposing (CellType)
import Dict exposing (Dict)


order : Order CellType String
order =
    Maybe.map CellType.name
        >> Maybe.withDefault ""


rules : List (Rule CellType)
rules =
    CellType.list
        |> List.map Rule.rules
        |> List.concat


automata : Automata CellType String
automata =
    CellAutomata.automata
        Neighborhood.fullSymmetry
        order
        rules


step : Dict ( Int, Int ) CellType -> ( Int, Int ) -> Maybe CellType -> Maybe CellType
step =
    CellAutomata.step
        automata
