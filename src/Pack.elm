module Pack exposing (..)

import Card exposing (Card)


type Pack
    = ForestFire
    | RabbitRampage
    | FireAndIce
    | FoodChain
    | CreepyCrawlies


asList : List Pack
asList =
    [ ForestFire
    , RabbitRampage
    , FireAndIce
    , FoodChain
    , CreepyCrawlies
    ]


cards : Pack -> List Card
cards pack =
    case pack of
        ForestFire ->
            [ Card.Tree, Card.Tree, Card.Water, Card.Fire ]

        RabbitRampage ->
            [ Card.Water, Card.Tree, Card.Rabbit, Card.Eagle, Card.Eagle ]

        FireAndIce ->
            [ Card.Volcano, Card.Volcano, Card.Water, Card.Snow ]

        FoodChain ->
            [ Card.Rabbit, Card.Tree, Card.Water, Card.Nest ]

        CreepyCrawlies ->
            [ Card.Butterfly, Card.Caterpillar, Card.Tree, Card.Tree ]


price : Pack -> Int
price pack =
    pack
        |> cards
        |> List.map Card.price
        |> List.sum
        |> (\int -> int * 3 // 4)
