module Automata.Rule exposing (rules)

import Automata.Neighborhood as Neighborhood
import CellAutomata exposing (Rule)
import Data.Card exposing (Card(..))


type RuleType
    = Surrounds Card
    | CombinesInto Card
    | TurnsInto Card
    | KilledBy Card
    | KilledBy2 Card
    | Spawns Card
    | Disapears
    | Transforms { by : List Card, to : Card }
    | Combines3 { by : Card, to : Card }


rule : { from : Maybe Card, to : Maybe Card } -> List ( Int, Maybe Card ) -> Rule Card
rule { from, to } list =
    { from = from, to = to, neighbors = Neighborhood.fromList list }


intoRule : RuleType -> (Card -> Rule Card)
intoRule ruleType =
    case ruleType of
        Surrounds to ->
            \containedBy -> rule { from = Nothing, to = Just to } [ ( 3, Just containedBy ) ]

        CombinesInto to ->
            \from -> rule { from = Just from, to = Just to } [ ( 3, Just from ) ]

        TurnsInto to ->
            \from -> rule { from = Just from, to = Just to } [ ( 1, Just to ) ]

        KilledBy2 by ->
            \from -> rule { from = Just from, to = Nothing } [ ( 2, Just by ) ]

        KilledBy by ->
            \from -> rule { from = Just from, to = Nothing } [ ( 1, Just by ) ]

        Spawns to ->
            \by -> rule { from = Nothing, to = Just to } [ ( 1, Just by ) ]

        Disapears ->
            \from -> rule { from = Just from, to = Nothing } []

        Transforms { by, to } ->
            \from -> rule { from = Just from, to = Just to } (List.map (\b -> ( 1, Just b )) by)

        Combines3 { by, to } ->
            \from -> rule { from = Just from, to = Just to } [ ( 2, Just by ) ]


rules : Card -> List (Rule Card)
rules cellType =
    (case cellType of
        Plant ->
            [ Combines3 { by = Cat, to = Tree }
            , Transforms { by = [ Mouse ], to = Mouse }
            ]

        Stone ->
            [ Combines3 { by = Mouse, to = Cat }
            , Combines3 { by = Plant, to = Mouse }
            ]

        Mouse ->
            [ TurnsInto Cat
            , KilledBy Plant
            ]

        Cat ->
            [ KilledBy Bear
            , KilledBy Mouse
            ]

        Tree ->
            [ Combines3 { by = Cat, to = Bear } ]

        Bear ->
            [ KilledBy Cat ]
    )
        |> List.map (intoRule >> (\f -> f cellType))
