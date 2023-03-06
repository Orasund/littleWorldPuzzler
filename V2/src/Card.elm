module Card exposing (..)


type Card
    = Fire
    | Water
    | Tree
    | Rabbit
    | Wolf


asList : List Card
asList =
    [ Fire, Water, Tree, Rabbit, Wolf ]


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


transform : List Card -> Card -> Maybe Card
transform neighbors card =
    case card of
        Water ->
            Nothing

        Tree ->
            if List.member Fire neighbors then
                Just Fire

            else
                Just card

        Fire ->
            if List.member Water neighbors then
                Nothing

            else
                Just card

        Rabbit ->
            if List.member Wolf neighbors then
                Just Wolf

            else
                Just card

        Wolf ->
            if not (List.member Rabbit neighbors) then
                Nothing

            else
                Just card


produce : List Card -> Card -> Maybe Card
produce neighbors card =
    case card of
        Water ->
            if neighbors /= [] then
                Just Water

            else
                Nothing

        Tree ->
            if List.member Water neighbors then
                Just Tree

            else
                Nothing

        Fire ->
            if [ Fire, Fire, Fire, Fire ] == neighbors then
                Just Fire

            else
                Nothing

        Rabbit ->
            if
                neighbors
                    |> List.filter ((==) Tree)
                    |> List.length
                    |> (\int -> int >= 2)
            then
                Just Rabbit

            else
                Nothing

        Wolf ->
            if [ Rabbit, Rabbit, Rabbit, Rabbit ] == neighbors then
                Just Wolf

            else
                Nothing


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
