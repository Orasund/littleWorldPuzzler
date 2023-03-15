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

        Snow ->
            "❄️"

        Eagle ->
            "🦅"


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
            ( Nothing, always True )

        Volcano ->
            ( Just Fire
            , \neighbors ->
                neighbors
                    |> List.filter ((==) Fire)
                    |> List.length
                    |> (\int -> int >= 2)
            )

        Snow ->
            ( Just Water, List.member Fire )

        Eagle ->
            ( Nothing, List.member Rabbit )


produces : Card -> ( Card, List Card -> Bool )
produces card =
    case card of
        Water ->
            ( card, (/=) [] )

        Tree ->
            ( card, List.member Water )

        Fire ->
            ( card
            , \neighbors ->
                neighbors
                    |> List.filter ((==) Fire)
                    |> List.length
                    |> (\int -> int >= 2)
            )

        Rabbit ->
            ( card
            , \neighbors ->
                neighbors
                    |> List.filter ((==) Tree)
                    |> List.length
                    |> (\int -> int >= 2)
            )

        Wolf ->
            ( card, List.member Rabbit )

        Volcano ->
            ( Fire, always True )

        Snow ->
            ( Snow, List.member Water )

        Eagle ->
            ( Eagle, List.member Rabbit )


price : Card -> Int
price card =
    case card of
        Water ->
            10

        Tree ->
            10

        Fire ->
            10

        Rabbit ->
            20

        Wolf ->
            20

        Eagle ->
            20

        Snow ->
            30

        Volcano ->
            40
