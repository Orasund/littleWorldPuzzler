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
            \from -> rule { from = Just from, to = Just to } (by |> List.map (\b -> ( 1, Just b )))

        Combines3 { by, to } ->
            \from -> rule { from = Just from, to = Just to } [ ( 2, Just by ) ]


rules : Card -> List (Rule Card)
rules cellType =
    (case cellType of
        Water ->
            [ Disapears
            , Surrounds Lake
            ]

        Plant ->
            [ Transforms { by = [ Worm ], to = Worm }

            --, Transforms { by = [ Water ], to = Tree }
            --, Combines3 { by = Plant, to = Tree }
            ]

        Cactus ->
            []

        Tree ->
            [ TurnsInto Fire
            , Transforms { by = [ Worm ], to = Bird }
            ]

        Stone ->
            [ -- Transforms { by = [ Water, Plant ], to = Worm }
              --Transforms { by = [ Tree ], to = Worm }
              --   Combines3 { by = Plant, to = Worm }
              Combines3 { by = Stone, to = Worm }
            ]

        Worm ->
            [ KilledBy Plant
            , TurnsInto Bird
            ]

        Bird ->
            [ KilledBy Worm ]

        Lake ->
            [ KilledBy2 Fire
            , TurnsInto Ice
            , Spawns Tree
            ]

        Fire ->
            [ Disapears
            , Surrounds Volcano
            ]

        Mountain ->
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
