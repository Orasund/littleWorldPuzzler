module Pack exposing (..)

import Card exposing (Card)


type Pack
    = IntroFire
    | IntroTree
    | RabbitRampage
    | IntroVolcano
    | FoodChain
    | IntroButterfly
    | IntroBird
    | IntroIce


asList : List Pack
asList =
    [ IntroFire
    , IntroTree
    , RabbitRampage
    , IntroVolcano
    , FoodChain
    , IntroButterfly
    , IntroBird
    , IntroIce
    ]
        |> List.sortBy price


cards : Pack -> List Card
cards pack =
    case pack of
        IntroFire ->
            [ Card.Fire, Card.Fire, Card.Fire, Card.Fire, Card.Water ]

        IntroTree ->
            [ Card.Tree, Card.Tree, Card.Water, Card.Water, Card.Fire ]

        IntroButterfly ->
            [ Card.Tree, Card.Tree, Card.Butterfly, Card.Butterfly ]

        RabbitRampage ->
            [ Card.Butterfly, Card.Butterfly, Card.Tree, Card.Rabbit, Card.Eagle ]

        IntroVolcano ->
            [ Card.Water, Card.Water, Card.Volcano, Card.Volcano ]

        FoodChain ->
            [ Card.Rabbit, Card.Rabbit, Card.Tree, Card.Tree, Card.Water, Card.Nest ]

        IntroBird ->
            [ Card.Tree, Card.Tree, Card.Butterfly, Card.Butterfly, Card.Bird, Card.Bird, Card.Bird, Card.Bird, Card.Bird ]

        IntroIce ->
            [  Card.Snow,Card.Snow,Card.Snow,Card.Water,Card.Volcano]


price : Pack -> Int
price pack =
    pack
        |> cards
        |> List.map Card.price
        |> List.sum


surviveTurns : Pack -> Int
surviveTurns pack =
    case pack of
        IntroFire ->
            20

        _ ->
            30
