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


transform : Card -> ( Maybe Card, List Card -> Bool )
transform card =
    case card of
        Water ->
            ( Nothing, always True )

        Tree ->
            ( Nothing
            , \line ->
                List.member Fire line
                    || List.member Rabbit line
                    || List.member Caterpillar line
            )

        Fire ->
            ( Nothing, List.member Water )

        Rabbit ->
            ( Nothing
            , \line ->
                List.member Wolf line
                    || List.member Eagle line
            )

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

        Nest ->
            ( Nothing
            , \neighbors ->
                neighbors
                    |> List.filter ((==) Fire)
                    |> List.length
                    |> (\int -> int >= 2)
            )

        Butterfly ->
            ( Just Caterpillar
            , \neighbors ->
                List.member Tree neighbors
            )

        Caterpillar ->
            ( Nothing
            , \neighbors ->
                neighbors
                    |> List.member Tree
                    |> not
            )


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
                (neighbors
                    |> List.filter ((==) Fire)
                    |> List.length
                    |> (\int -> int >= 2)
                )
                    || List.member Tree neighbors
            )

        Rabbit ->
            ( card
            , List.member Tree
            )

        Wolf ->
            ( card, List.member Rabbit )

        Volcano ->
            ( Fire, always True )

        Snow ->
            ( Snow, List.member Water )

        Eagle ->
            ( card, List.member Rabbit )

        Nest ->
            ( Eagle, always True )

        Butterfly ->
            ( Tree, List.member Tree )

        Caterpillar ->
            ( Butterfly, List.member Tree )


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
