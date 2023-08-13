module Data.Card exposing
    ( Card(..)
    , list
    , name
    , toString
    )


type Card
    = Wood
    | Water
    | Fire
    | Stone
    | Volcano
    | Glacier
    | Ice
    | Snow
    | Evergreen
    | Weed


list : List Card
list =
    [ Snow, Fire, Glacier, Volcano, Stone, Evergreen, Ice, Water, Wood, Weed ]


toString : Card -> String
toString cellType =
    String.fromChar <|
        case cellType of
            Wood ->
                '🌳'

            Water ->
                '🌊'

            Fire ->
                '🔥'

            Stone ->
                '⛰'

            Volcano ->
                '🌋'

            Glacier ->
                '🏔'

            Ice ->
                '❄'

            Snow ->
                '⛄'

            Evergreen ->
                '🌲'

            Weed ->
                '🌿'


name : Card -> String
name cellType =
    case cellType of
        Wood ->
            "Wood"

        Water ->
            "Water"

        Fire ->
            "Fire"

        Stone ->
            "Stone"

        Volcano ->
            "Volcano"

        Glacier ->
            "Glacier"

        Ice ->
            "Ice"

        Snow ->
            "Snow"

        Evergreen ->
            "Evergreen Tree"

        Weed ->
            "Weed"
