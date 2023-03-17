module Card exposing (..)


type Card
    = Fire
    | Water
    | Tree
    | Rabbit
    | Wolf
    | Volcano
    | Snow
    | Eagle
    | Nest
    | Butterfly
    | Caterpillar


type NeighborExpression
    = Either (List NeighborExpression)
    | NextTo Card
    | NextToAtLeast Int Card
    | Not NeighborExpression
    | Anything
    | Something


asList : List Card
asList =
    [ Water
    , Fire
    , Tree
    , Rabbit
    , Wolf
    , Volcano
    , Snow
    , Eagle
    , Nest
    , Butterfly
    , Caterpillar
    ]


isValidNeighborhoods : List Card -> NeighborExpression -> Bool
isValidNeighborhoods neighborhood exp =
    case exp of
        Either exps ->
            exps |> List.any (isValidNeighborhoods neighborhood)

        NextTo card ->
            neighborhood |> List.member card

        NextToAtLeast amount card ->
            neighborhood
                |> List.filter ((==) card)
                |> List.length
                |> (\int -> int >= amount)

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

        Wolf ->
            "🐺"

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
            ( Nothing, NextTo Water )

        Rabbit ->
            ( Nothing
            , Either [ NextTo Wolf, NextTo Eagle ]
            )

        Wolf ->
            ( Nothing, Anything )

        Volcano ->
            ( Just Fire
            , NextToAtLeast 2 Fire
            )

        Snow ->
            ( Just Water, NextTo Fire )

        Eagle ->
            ( Nothing, NextTo Rabbit )

        Nest ->
            ( Nothing
            , NextToAtLeast 2 Fire
            )

        Butterfly ->
            ( Just Caterpillar
            , NextTo Tree
            )

        Caterpillar ->
            ( Nothing
            , Not (NextTo Tree)
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
                [ NextToAtLeast 2 Fire
                , NextTo Tree
                ]
            )

        Rabbit ->
            ( card
            , NextTo Tree
            )

        Wolf ->
            ( card, NextTo Rabbit )

        Volcano ->
            ( Fire, Anything )

        Snow ->
            ( Snow, NextTo Water )

        Eagle ->
            ( card, NextTo Rabbit )

        Nest ->
            ( Eagle, Anything )

        Butterfly ->
            ( Tree, NextTo Tree )

        Caterpillar ->
            ( Butterfly, NextTo Tree )


price : Card -> Int
price card =
    case card of
        Water ->
            0

        Tree ->
            0

        Fire ->
            0

        Rabbit ->
            10

        Wolf ->
            10

        Eagle ->
            10

        Snow ->
            20

        Volcano ->
            30

        Nest ->
            30

        Butterfly ->
            20

        Caterpillar ->
            10
