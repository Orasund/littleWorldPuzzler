module Card exposing (..)


type Card
    = Fire
    | Water
    | Tree
    | Rabbit
    | Volcano
    | Snow
    | Eagle
    | Nest
    | Butterfly
    | Caterpillar
    | Bird


type NeighborExpression
    = Either (List NeighborExpression)
    | NextTo Card
    | NextToTwo Card
    | Not NeighborExpression
    | Anything
    | Something


isValidNeighborhoods : List Card -> NeighborExpression -> Bool
isValidNeighborhoods neighborhood exp =
    case exp of
        Either exps ->
            exps |> List.any (isValidNeighborhoods neighborhood)

        NextTo card ->
            neighborhood |> List.member card

        NextToTwo card ->
            neighborhood
                |> List.filter ((==) card)
                |> List.length
                |> (\int -> int >= 2)

        Not e ->
            not (isValidNeighborhoods neighborhood e)

        Anything ->
            True

        Something ->
            neighborhood /= []


emoji : Card -> String
emoji card =
    case card of
        Fire ->
            "🔥"

        Water ->
            "💧"

        Tree ->
            "🌳"

        Rabbit ->
            "🐰"

        Volcano ->
            "🌋"

        Snow ->
            "❄️"

        Eagle ->
            "🦅"

        Nest ->
            "\u{1FABA}"

        Butterfly ->
            "🦋"

        Caterpillar ->
            "🐛"

        Bird ->
            "🐦"


transform : Card -> ( Maybe Card, NeighborExpression )
transform card =
    case card of
        Water ->
            ( Nothing, Anything )

        Tree ->
            ( Nothing
            , Either
                [ NextTo Fire
                , NextTo Rabbit
                , NextTo Caterpillar
                ]
            )

        Fire ->
            ( Nothing
            , NextTo Water
            )

        Rabbit ->
            ( Nothing
            , NextTo Eagle
            )

        Volcano ->
            ( Just Fire
            , NextToTwo Fire
            )

        Snow ->
            ( Just Water, NextTo Fire )

        Eagle ->
            ( Nothing, NextTo Rabbit )

        Nest ->
            ( Nothing
            , NextToTwo Fire
            )

        Butterfly ->
            ( Just Caterpillar
            , NextTo Tree
            )

        Caterpillar ->
            ( Nothing
            , Either
                [ NextTo Bird
                , Not (NextTo Tree)
                ]
            )

        Bird ->
            ( Nothing
            , NextTo Caterpillar
            )


produces : Card -> ( Card, NeighborExpression )
produces card =
    case card of
        Water ->
            ( card, Something )

        Tree ->
            ( card, NextTo Water )

        Fire ->
            ( card
            , Either
                [ NextToTwo Fire
                , NextTo Tree
                ]
            )

        Rabbit ->
            ( card
            , NextTo Tree
            )

        Volcano ->
            ( Fire, Anything )

        Snow ->
            ( Snow, NextTo Water )

        Eagle ->
            ( card
            , Either
                [ NextTo Rabbit
                , NextTo Eagle
                ]
            )

        Nest ->
            ( Eagle, Anything )

        Butterfly ->
            ( Tree, NextTo Tree )

        Caterpillar ->
            ( Butterfly, NextTo Tree )

        Bird ->
            ( card
            , Either
                [ NextTo Caterpillar
                , NextToTwo Bird
                ]
            )


price : Card -> Int
price card =
    case card of
        Water ->
            0

        Tree ->
            5

        Fire ->
            0

        Rabbit ->
            5

        Eagle ->
            5

        Snow ->
            5

        Volcano ->
            5

        Nest ->
            5

        Butterfly ->
            5

        Caterpillar ->
            5

        Bird ->
            5
