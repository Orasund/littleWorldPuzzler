module Card exposing (..)


type Card
    = Fire
    | Water
    | Tree
    | Rabbit
    | Wolf
    | Volcano
    | Snow


asList : List Card
asList =
    [ Water
    , Fire
    , Tree
    , Rabbit
    , Wolf
    , Volcano
    , Snow
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
            ( Nothing, List.member Fire )

        Snow ->
            ( Just Water, List.member Fire )


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

        Snow ->
            ( Snow, List.member Water )


price : Card -> Int
price card =
    case card of
        Water ->
            5

        Tree ->
            5

        Fire ->
            5

        Rabbit ->
            5

        Wolf ->
            10

        Snow ->
            15

        Volcano ->
            20
