module Pack exposing (..)

import Card exposing (Card)


type Pack
    = ForestFire
    | RabbitRampage
    | FireAndIce


asList : List Pack
asList =
    [ ForestFire, RabbitRampage, FireAndIce ]


cards : Pack -> List Card
cards pack =
    case pack of
        ForestFire ->
            [ Card.Tree, Card.Tree, Card.Water, Card.Fire ]

        RabbitRampage ->
            [ Card.Tree, Card.Tree, Card.Rabbit, Card.Wolf ]

        FireAndIce ->
            [ Card.Volcano, Card.Volcano, Card.Water, Card.Snow ]


price : Pack -> Int
price pack =
    pack
        |> cards
        |> List.map Card.price
        |> List.sum
        |> (\int -> int * 3 // 4)
