module  View.Rule exposing (view)

import Element exposing (Element)
import  Automata.Neighborhood as Neighborhood
import  Automata.Rule as Rule
import  Data.CellType as CellType exposing (CellType(..))


view : CellType -> List (Element msg)
view =
    Rule.rules
        >> List.map
            (\{ from, to, neighbors } ->
                Element.text <|
                    (from |> Maybe.map CellType.toString |> Maybe.withDefault " ")
                        ++ "➕"
                        ++ Neighborhood.toString neighbors
                        ++ "➡"
                        ++ (to |> Maybe.map CellType.toString |> Maybe.withDefault " ")
            )
