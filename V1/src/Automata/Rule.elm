module Automata.Rule exposing (rules)

import Automata.Neighborhood as Neighborhood
import CellAutomata exposing (Rule)
import Data.CellType exposing (CellType(..))


type RuleType
    = Surrounds CellType
    | CombinesInto CellType
    | TurnsInto CellType
    | KilledBy CellType
    | KilledBy2 CellType
    | Spawns CellType
    | Disapears


rule : { from : Maybe CellType, to : Maybe CellType } -> List ( Int, Maybe CellType ) -> Rule CellType
rule { from, to } list =
    { from = from, to = to, neighbors = Neighborhood.fromList list }


intoRule : RuleType -> (CellType -> Rule CellType)
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


rules : CellType -> List (Rule CellType)
rules cellType =
    (case cellType of
        Wood ->
            [ TurnsInto Fire
            , CombinesInto Evergreen
            , Surrounds Weed
            ]

        Water ->
            [ KilledBy2 Fire
            , TurnsInto Ice
            , Spawns Wood
            ]

        Fire ->
            [ Disapears
            , Surrounds Volcano
            ]

        Stone ->
            [ CombinesInto Glacier
            , KilledBy Glacier
            ]

        Volcano ->
            [ Disapears
            , Spawns Fire
            ]

        Glacier ->
            [ KilledBy Fire
            , Spawns Ice
            ]

        Ice ->
            [ Disapears
            , Surrounds Snow
            ]

        Snow ->
            [ KilledBy2 Fire
            ]

        Evergreen ->
            [ KilledBy Fire
            ]

        Weed ->
            [ TurnsInto Fire
            , Spawns Weed
            ]
    )
        |> List.map (intoRule >> (\f -> f cellType))
