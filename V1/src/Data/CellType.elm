module Data.CellType exposing
    ( CellType(..)
    , list
    , name
    , toString
    )


type CellType
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


list : List CellType
list =
    [ Snow, Fire, Glacier, Volcano, Stone, Evergreen, Ice, Water, Wood, Weed ]


toString : CellType -> String
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


name : CellType -> String
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
