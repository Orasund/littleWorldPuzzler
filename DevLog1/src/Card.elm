module Card exposing (..)


type Card
    = Fire
    | Water
    | Tree


emoji : Card -> String
emoji card =
    case card of
        Fire ->
            "🔥"

        Water ->
            "💧"

        Tree ->
            "🌳"


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


produce : List Card -> Card -> Maybe Card
produce neighbors card =
    case card of
        Water ->
            Just Water

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
