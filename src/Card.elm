module Card exposing (..)


type Card
    = Fire
    | Water
    | Tree
    | Rabbit
    | Wolf
    | Volcano


asList : List Card
asList =
    [ Water
    , Fire
    , Tree
    , Rabbit
    , Wolf
    , Volcano
    ]


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


transform : Card -> ( Maybe Card, List Card -> Bool )
transform card =
    case card of
        Water ->
            ( Nothing, always True )

        Tree ->
            ( Just Fire, List.member Fire )

        Fire ->
            ( Nothing, List.member Water )

        Rabbit ->
            ( Just Wolf, List.member Wolf )

        Wolf ->
            ( Nothing, List.member Rabbit )

        Volcano ->
            ( Nothing, List.member Fire )


produces : Card -> ( Card, List Card -> Bool )
produces card =
    case card of
        Water ->
            ( card, (/=) [] )

        Tree ->
            ( card, List.member Water )

        Fire ->
            ( card, (==) (List.repeat 4 Fire) )

        Rabbit ->
            ( card
            , \neighbors ->
                neighbors
                    |> List.filter ((==) Tree)
                    |> List.length
                    |> (\int -> int >= 2)
            )

        Wolf ->
            ( card, (==) (List.repeat 4 Rabbit) )

        Volcano ->
            ( Fire, always True )


price : Card -> Int
price card =
    case card of
        Water ->
            20

        Tree ->
            10

        Fire ->
            10

        Rabbit ->
            10

        Wolf ->
            15

        Volcano ->
            30
