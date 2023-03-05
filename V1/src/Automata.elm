module  Automata exposing (step)

import CellAutomata exposing (Automata, Order, Rule)
import Dict exposing (Dict)
import  Automata.Neighborhood as Neighborhood
import  Automata.Rule as Rule
import  Data.CellType as CellType exposing (CellType)


order : Order CellType Int
order =
    Maybe.map CellType.toInt
        >> Maybe.withDefault 0


rules : List (Rule CellType)
rules =
    CellType.list
        |> List.map Rule.rules
        |> List.concat


automata : Automata CellType Int
automata =
    CellAutomata.automata
        Neighborhood.fullSymmetry
        order
        rules


step : Dict ( Int, Int ) CellType -> ( Int, Int ) -> Maybe CellType -> Maybe CellType
step =
    CellAutomata.step
        automata
